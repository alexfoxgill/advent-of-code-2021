input = File.stream!("day22/input.txt")

defmodule Input do
  def parse(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [inst, line] = String.split(line, " ")

    range =
      String.split(line, ",")
      |> Enum.map(&String.split(&1, "="))
      |> Map.new(fn [axis, range] -> {String.to_atom(axis), parse_range(range)} end)

    range =
      cond do
        range.x.last < -50 -> MapSet.new()
        range.x.first > 50 -> MapSet.new()
        range.y.last < -50 -> MapSet.new()
        range.y.first > 50 -> MapSet.new()
        range.z.last < -50 -> MapSet.new()
        range.z.first > 50 -> MapSet.new()
        true -> for x <- range.x, y <- range.y, z <- range.z, into: MapSet.new(), do: {x, y, z}
      end

    {String.to_atom(inst), range}
  end

  defp parse_range(range) do
    [from, to] = String.split(range, "..") |> Enum.map(&String.to_integer/1)
    max(from, -50)..min(to, 50)
  end
end

input
|> Input.parse()
|> Enum.reduce(MapSet.new(), fn
  {:on, range}, set -> MapSet.union(set, range)
  {:off, range}, set -> MapSet.difference(set, range)
end)
|> MapSet.size()
|> IO.inspect()
