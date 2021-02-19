defmodule StateMachine.Interpreter do
  @doc """
  This module implements an Amazon States Language interpreter using the StatesLanguage package.

  The StatesLanguage package is designed for state machines defined at compile time, there is no support for dynamic
  state machines [0].

  The way around this is to dynamically compile the state machine module at runtime. The `start_execution` function
  creates a quoted expression defining the state machine module by calling the `states_language_machine` function.
  After that:
   * it proceeds to compile the quoted expression to a module
   * starts the state machine
   * starts monitoring the state machine process
   * waits for the state machine to terminate and then cleanups the resources used (module and definition file)

  ## See also

  [0] https://github.com/entropealabs/states_language/issues/9
  """
  defmodule Context do
    defstruct [:workflow, :execution, :resources, :reply_to, :state_machine]
  end

  require Logger

  def create_context(workflow, execution, opts \\ []) do
    config = interpreter_configuration()
    resources = Keyword.get(config, :resources)
    reply_to = Keyword.get(opts, :reply_to)
    state_machine = workflow.definition

    %Context{
      workflow: workflow,
      execution: execution,
      resources: resources,
      reply_to: reply_to,
      state_machine: state_machine
    }
  end

  def start_execution(workflow, execution, opts \\ []) do
    context = create_context(workflow, execution, opts)
    try do
      {:ok, temp_json_name} = Temp.path %{prefix: "states-language", suffix: ".json"}
      File.write(temp_json_name, Jason.encode!(context.state_machine))
      quoted_state_machine = states_language_machine(context.execution.id, temp_json_name, context.reply_to)

      [{mod, _}] = Code.compile_quoted(quoted_state_machine)
      {:ok, pid} = mod.start_link(context.execution.arguments)
      Process.monitor(pid)
      receive do
        {:DOWN, _ref, :process, _object, _reason} ->
          :code.delete mod
          :code.purge mod
          File.rm(temp_json_name)
      end
    rescue
      err -> Logger.debug("Err: #{inspect err}")
    end
  end


  defp interpreter_configuration() do
    Application.fetch_env!(:realtime, StateMachine)
  end

  defp states_language_machine(suffix, state_machine, reply_to) do
    state_machine = Macro.escape(state_machine)
    quote do
      defmodule unquote(:"StateMachine_#{suffix}") do
        use StatesLanguage, data: unquote(state_machine)

        require Logger

        def handle_resource(resource, params, state_name, data) do
          Logger.info("Resource #{inspect resource}, #{inspect params}")
          {:ok, data, []}
        end

        def handle_termination(reason, state_name, %StatesLanguage{data: data}) do
          Logger.info("terminate #{inspect reason} #{inspect state_name} #{inspect data}")
          if unquote(reply_to) != nil do
            send unquote(reply_to), {:ok, data}
          end
          :ok
        end
      end
    end
  end
end
