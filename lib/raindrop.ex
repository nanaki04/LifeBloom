defmodule LifeBloom.Raindrop do
  @moduledoc """
  Behaviour defining raindrops, modifiers that form the pipeline for every
  single branch function that makes up an entangled function composition.

  callbacks:
  @spec init(atom) :: init_result
  @spec fall(rainfall) :: rainfall
  """

  @type init_result :: :ok | {:error, String.t}
  @type rainfall :: (LifeBloom.Entangle.state -> LifeBloom.Entangle.state)

  @callback init(atom) :: init_result
  @callback fall(rainfall) :: rainfall

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour LifeBloom.Raindrop

      import LifeBloom.Raindrop

      @doc false
      def init(_targetModule) do
        :ok
      end

      @doc false
      def fall(rainfall) do
        fn state -> apply rainfall, [state] end
      end

      defoverridable [init: 1, fall: 1]
    end
  end

end
