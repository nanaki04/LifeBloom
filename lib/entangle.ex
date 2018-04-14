defmodule LifeBloom.Entangle do
  @moduledoc """
  Module for making function compositions including pipelines to be traversed on
  calling the result composed function, and the individual functions that make
  up the composition.

  The pipelines are composed of the following elements:
    Raindrops: the pipeline of raindrops will be traversed for every individual branch function call
    Vitalizers: the pipeline of vitalizers will be traversed upon calling the composed function

  Raindrops and vitalizers can be passed as option to the use macro:

    use LifeBloom.Entangle, raindrops: [raindrop1], vitalizers: [vitalizer1, vitalizer2]

  Both Raindrops and Vitalizers can be used to make development easier by adding loggers,
  mock data providers and the like.

  Vitalizers in particular can be used for adding adapters, so the same code can be re-used even if the
  state object differs slightly, or state objects from modules not under ones own control need to be
  integrated.

  Raindrops in particular can be used for adding conditions and breaks to the composed function stack.
  """

  @type state :: any
  @type grove :: (state -> state)
  @type branch :: (state -> state)

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import LifeBloom.Entangle

      Module.register_attribute __MODULE__, :raindrops, []
      Module.register_attribute __MODULE__, :vitalizers, []
      @raindrops Keyword.get(opts, :raindrops, [])
      @vitalizers Keyword.get(opts, :vitalizers, [])
      true = Enum.all? @raindrops, fn raindrop -> :ok == raindrop.init(__MODULE__) end
      true = Enum.all? @vitalizers, fn vitalizer -> :ok == vitalizer.init(__MODULE__) end
    end
  end

  @doc """
  Composes a list of functions, enclosed by a pipeline:
    Raindrops: the pipeline of raindrops will be traversed for every individual branch function call
    Vitalizers: the pipeline of vitalizers will be traversed upon calling the composed function

  The atom to be passed as first parameter will be the name of the composed function.
  The second parameter will be a list of branch functions from which to compose the new function.
  Additional parameters for the branch functions can be inserted into the branch macro.

  ## Examples

      iex> defmodule Drop do
      ...>   use LifeBloom.Raindrop
      ...>
      ...>   def fall(next) do
      ...>     fn state -> apply next, [state + 1] end
      ...>   end  
      ...> end
      ...>
      ...> defmodule Vitalizer do
      ...>   use LifeBloom.Vitalizer
      ...>
      ...>   def vitalize(next) do
      ...>     fn state -> apply next, [state * 10] end
      ...>   end
      ...> end
      ...>
      ...> defmodule EntangleExample do
      ...>   use LifeBloom.Entangle, raindrops: [Drop], vitalizers: [Vitalizer]
      ...>
      ...>   def double(x, y), do: x * y
      ...>   def add2(x), do: x + 2
      ...>
      ...>   entangle :run, [
      ...>     branch(&double/2, 2),
      ...>     branch(&add2/1),
      ...>   ]
      ...> end
      ...>
      ...> state = 3
      ...> EntangleExample.run state
      65

  """
  defmacro entangle(name, branches) do
    quote do
      def unquote(name)(state) do
        grove = fn state -> Enum.reduce(unquote(branches), state, fn branch, state -> apply branch, [state] end) end
        @vitalizers
        |> Enum.reverse
        |> Enum.reduce(grove, fn vitalizer, next -> apply vitalizer, :vitalize, [next] end)
        |> (fn bloom, state -> bloom.(state) end).(state)
      end
    end
  end

  defmacro branch(seed) do
    grow_branch seed, []
  end

  defmacro branch(seed, nurishment) do
    grow_branch seed, [nurishment]
  end

  defmacro branch(seed, nurishment1, nurishment2) do
    grow_branch seed, [nurishment1, nurishment2]
  end

  defmacro branch(seed, nurishment1, nurishment2, nurishment3) do
    grow_branch seed, [nurishment1, nurishment2, nurishment3]
  end

  defp grow_branch(seed, nurishments) do
    quote do
      sapling = apply LifeBloom.Bloom, :sow, [unquote(seed) | unquote(nurishments)]
      @raindrops
      |> Enum.reverse
      |> Enum.reduce(sapling, fn raindrop, next -> apply raindrop, :fall, [next] end)
    end
  end

end
