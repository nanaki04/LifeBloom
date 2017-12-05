defmodule LifeBloom.Vitalizer do
  @moduledoc """
  Behaviour defining vitalizers, modifiers that form the pipeline for
  an entangled function composition.

  callbacks:
  @spec init(atom) :: init_result
  @spec vitalize(vitalizer) :: vitalizer
  """

  @type init_result :: :ok | {:error, String.t}
  @type vitalizer :: (LifeBloom.Entangle.state -> LifeBloom.Entangle.state)

  @callback init(atom) :: init_result
  @callback vitalize(vitalizer) :: vitalizer

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour LifeBloom.Vitalizer

      import LifeBloom.Vitalizer

      @doc false
      def init(_targetModule) do
        :ok
      end

      @doc false
      def vitalize(vitalizer) do
        fn state -> apply vitalizer, [state] end
      end

      defoverridable [init: 1, vitalize: 1]
    end
  end

end
