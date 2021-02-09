defmodule RealtimeWeb.ErrorController do
  use RealtimeWeb, :controller

  require Logger

  def call(conn, {:error, %Ecto.Changeset{} = _changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(RealtimeWeb.ErrorView)
    |> render("400.json", %{})
  end

  def call(conn, {:not_found, id}) do
    conn
    |> put_status(:not_found)
    |> put_view(RealtimeWeb.ErrorView)
    |> render("404.json", %{})
  end

  def call(conn, error) do
    Logger.debug("ErrorController.call: #{inspect error}")
    conn
    |> put_view(RealtimeWeb.ErrorView)
    |> render("500.json", %{})
  end

end
