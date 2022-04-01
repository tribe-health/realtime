defmodule RealtimeWeb.RoomChannel do
  use RealtimeWeb, :channel

  alias RealtimeWeb.{Endpoint, Presence}
  alias Phoenix.Socket
  alias Phoenix.Socket.Broadcast

  @impl true
  def join(
        "room:" <> sub_topic,
        _,
        %{assigns: %{tenant: tenant, claims: claims}, transport_pid: transport_pid} = socket
      ) do
    # topic: "public:messages:room_id=eq.B4x7oSvwiYY9d3R1qrbuQ"
    tenant_topic = tenant <> ":" <> sub_topic

    Endpoint.subscribe(tenant_topic)

    id = UUID.uuid1()

    if sub_topic != "*" do
      Extensions.Postgres.subscribe(tenant, id, sub_topic, claims, transport_pid)
    end

    send(self(), :after_join)

    {:ok, assign(socket, %{id: id, tenant_topic: tenant_topic})}
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
        %Socket{assigns: %{tenant_topic: tenant_topic}} = socket
      ) do
    Endpoint.broadcast_from(self(), tenant_topic, type, payload)
    {:noreply, socket}
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
