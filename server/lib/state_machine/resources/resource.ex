defmodule StateMachine.Resources.Resource do
  @callback can_handle(String.t()) :: boolean()
  @callback call(String.t(), any()) :: {:ok, any()} | {:error, any()}
end
