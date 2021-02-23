defmodule StateMachine.Resources.HttpEndpoint do
  @moduledoc false

  require Logger

  def can_handle(name) do
    String.starts_with?(name, "https://") || String.starts_with?(name, "http://")
  end

  def call(_name, args) do
    Logger.info("Call HttpEndpoint with args #{inspect args}")
    {:ok, args}
  end
end
