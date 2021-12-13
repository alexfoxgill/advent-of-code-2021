input = File.stream!("day7/input.txt")

ints =
  input
  |> Stream.flat_map(&String.split(&1, ","))
  |> Stream.map(&String.to_integer/1)
  |> Enum.to_list()

{sum, count} = ints |> Enum.reduce({0, 0}, fn x, {sum, count} -> {sum + x, count + 1} end)
avg = round(sum / count)

defmodule Calc do
  def summation(n) do
    n * (n + 1) / 2
  end

  def calculate(cache, ints, target) do
    case Map.fetch(cache, target) do
      {:ok, val} ->
        {cache, val}

      _ ->
        res = ints |> Enum.reduce(0, fn x, total -> total + summation(abs(x - target)) end)
        {Map.put(cache, target, res), res}
    end
  end

  def calculate_min(cache, ints, target) do
    {cache, t0} = calculate(cache, ints, target - 1)
    {cache, t1} = calculate(cache, ints, target)

    if t0 < t1 do
      calculate_min(cache, ints, target - 1)
    else
      {cache, t2} = calculate(cache, ints, target + 1)

      if t2 < t1 do
        calculate_min(cache, ints, target + 1)
      else
        t1
      end
    end
  end
end

Calc.calculate_min(%{}, ints, avg) |> IO.inspect()
