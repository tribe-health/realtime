defmodule MultiplayerWeb.RoomChannel do
  use MultiplayerWeb, :channel

  alias MultiplayerWeb.{Endpoint, Presence}
  alias Phoenix.Socket
  alias Phoenix.Socket.Broadcast

  @impl true
  def join(
        "room:" <> sub_topic,
        params,
        %{assigns: %{tenant: tenant, claims: claims}, transport_pid: transport_pid} = socket
      ) do
    self_broadcast = is_map(params) && Map.get(params, "self_broadcast", false)

    tenant_topic = tenant <> ":" <> sub_topic

    Endpoint.subscribe(tenant_topic)

    id = UUID.uuid1()

    postgres_topic =
      is_map(params) &&
        get_in(params, ["configs", "realtime", "eventFilter"])
        |> case do
          %{"schema" => schema, "table" => table, "filter" => filter} ->
            "#{schema}:#{table}:#{filter}"

          %{"schema" => schema, "table" => table} ->
            "#{schema}:#{table}"

          %{"schema" => schema} ->
            "#{schema}"

          _ ->
            ""
        end

    if postgres_topic != "" do
      Ewalrus.subscribe(tenant, id, postgres_topic, claims, transport_pid)
    end

    send(self(), :after_join)

    {:ok, assign(socket, %{id: id, self_broadcast: self_broadcast, tenant_topic: tenant_topic})}
  end

  @impl true
  def handle_info(:after_join, %Socket{assigns: %{tenant_topic: tenant_topic}} = socket) do
    push(socket, "presence_state", Presence.list(tenant_topic))
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Broadcast{event: type, payload: payload}, socket) do
    push(socket, type, payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("access_token", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_in(
        "broadcast" = type,
        payload,
        %Socket{assigns: %{self_broadcast: self_broadcast, tenant_topic: tenant_topic}} = socket
      ) do
    ack = Map.get(payload, "ack", false)

    if self_broadcast do
      Endpoint.broadcast(tenant_topic, type, payload)
    else
      Endpoint.broadcast_from(self(), tenant_topic, type, payload)
    end

    if ack do
      {:reply, :ok, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_in(
        "presence",
        %{"event" => "TRACK", "payload" => payload} = msg,
        %Socket{assigns: %{id: id, tenant_topic: tenant_topic}} = socket
      ) do
    case Presence.track(self(), tenant_topic, Map.get(msg, "key", id), payload) do
      {:ok, _} ->
        :ok

      {:error, {:already_tracked, _, _, _}} ->
        Presence.update(self(), tenant_topic, Map.get(msg, "key", id), payload)
    end

    {:reply, :ok, socket}
  end

  @impl true
  def handle_in(
        "presence",
        %{"event" => "UNTRACK"} = msg,
        %Socket{assigns: %{id: id, tenant_topic: tenant_topic}} = socket
      ) do
    Presence.untrack(self(), tenant_topic, Map.get(msg, "key", id))

    {:reply, :ok, socket}
  end
end
