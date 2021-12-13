# part 1 is just a different number of iterations
input = File.stream!("day6/input.txt")

initial_map =
  input
  |> Stream.flat_map(&String.split(&1, ","))
  |> Stream.map(&String.to_integer/1)
  |> Enum.reduce(%{}, fn x, map -> map |> Map.update(x, 1, &(&1 + 1)) end)

initial = 0..8 |> Enum.map(fn x -> Map.get(initial_map, x, 0) end)

defmodule Calc do
  def step([spawners | rest]) do
    List.update_at(rest, 6, &(&1 + spawners)) ++ [spawners]
  end
end

initial
|> Stream.iterate(&Calc.step/1)
|> Enum.at(256)
|> Enum.sum()
|> IO.inspect()
