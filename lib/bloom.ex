defmodule LifeBloom.Bloom do
  @moduledoc """
  The Bloom module implements a currying system.
  To be used smoothly with Elixir, I have provided the option to provide the first argument,
  in elixir usually the most important state, provided with the pipe operator, as the final curried argument.
  """

  @type tree :: any
  @type seed :: fun
  @type nurishment :: any
  @type sapling :: seed | tree
  @type order :: :normal
    | :state_first
  @type option :: {:order, order}
  @type options :: [option]

  @doc """
  The sow function is used to initialize the curry.

  ## Examples

      iex> import LifeBloom.Bloom
      ...> state = 6
      ...> seed = sow(fn x, y -> x / y end)
      ...> seed = nurish seed, 2
      ...> state |> bloom(seed)
      3.0

  """
  @spec sow(seed) :: sapling
  def sow(seed) do
    plant seed, []
  end

  @doc """
  Initialize the curry with one argument fixed.

  ## Examples

      iex> import LifeBloom.Bloom
      ...> state = 6
      ...> seed = sow(fn x, y, z -> x + y + z end, 3)
      ...> seed = nurish seed, 2
      ...> state |> bloom(seed)
      11

  """
  @spec sow(seed, nurishment) :: sapling
  def sow(seed, nurishment) do
    plant seed, [nurishment]
  end

  @doc """
  Initialize the curry with two argument fixed.
  """
  @spec sow(seed, nurishment, nurishment) :: sapling
  def sow(seed, nurishment1, nurishment2) do
    plant seed, [nurishment1, nurishment2]
  end

  @doc """
  Initialize the curry with three argument fixed.
  """
  @spec sow(seed, nurishment, nurishment, nurishment) :: sapling
  def sow(seed, nurishment1, nurishment2, nurishment3) do
    plant seed, [nurishment1, nurishment2, nurishment3]
  end

  @doc """
  Provide the curry with an argument.
  Alternatively you can call the curry by yourself.

  When all arguments are provided the function will be executed.

  ## Examples

      iex> import LifeBloom.Bloom
      ...> state = "hi"
      ...> seed = sow fn x, y -> x <> y end
      ...> nurishedSeed = nurish seed, " lol"
      ...> state |> bloom(nurishedSeed)
      "hi lol"

      iex> import LifeBloom.Bloom
      ...> seed = sow fn x, y -> x <> y end
      ...> curriedFunction = seed.("hi")
      ...> curriedFunction.(" lol")
      "hi lol"

      iex> import LifeBloom.Bloom
      ...> seed = sow fn x, y -> x <> y end
      ...> nurishedSeed = nurish seed, "hi"
      ...> nurish nurishedSeed, " lol"
      "hi lol"

  """
  @spec nurish(seed, nurishment) :: sapling
  def nurish(seed, nurishment) do
    seed.(nurishment)
  end

  @doc """
  Provide the curry with two arguments.
  """
  @spec nurish(seed, nurishment, nurishment) :: sapling
  def nurish(seed, nurishment1, nurishment2) do
    seed.(nurishment1).(nurishment2)
  end

  @doc """
  Provide the final argument to the curried function.
  The order of the argument and the function is opposite to that of the nurish function.
  This way the final argument, generally the most significant or state,
  can be provided through the pipeline.
  """
  @spec bloom(nurishment, seed) :: tree
  def bloom(finalNurishment, seed) do
    seed.({finalNurishment, [order: :state_first]})
  end

  defp plant(seed, nurishments) do
    {_, arity} = :erlang.fun_info(seed, :arity)
    plant seed, arity - length(nurishments), nurishments
  end

  defp plant(seed, 0, [{head, [order: :state_first]} | tail]) do
    apply seed, [head | Enum.reverse tail]
  end

  defp plant(seed, 0, nurishment) do
    apply seed, Enum.reverse nurishment
  end

  defp plant(seed, arity, nurishments) do
    fn nurishment -> plant seed, arity - 1, [nurishment | nurishments] end
  end

end
