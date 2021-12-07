input = File.stream!("day6/input-sample.txt")

initial =
  input
  |> Stream.flat_map(&String.split(&1, ","))
  |> Stream.map(&String.to_integer/1)
  |> Enum.reduce(%{}, fn x, map -> map |> Map.update(x, 1, &(&1 + 1)) end)

defmodule Calc do
  def step(map) do
  end
end
