input = File.stream!("day5/input.txt")

defmodule Input do
  def parse_line(line) do
    line_regex = ~r/(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/

    Regex.named_captures(line_regex, line)
    |> Map.new(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
  end
end

defmodule Line do
  def is_diagonal(line) do
    case line do
      %{x1: x, x2: x} -> false
      %{y1: y, y2: y} -> false
      _ -> true
    end
  end

  def get_points(line) do
    if is_diagonal(line) do
      line.x1..line.x2
      |> Enum.zip(line.y1..line.y2)
    else
      for x <- line.x1..line.x2, y <- line.y1..line.y2, do: {x, y}
    end
  end
end

input
|> Stream.map(&Input.parse_line/1)
|> Stream.flat_map(&Line.get_points/1)
|> Enum.group_by(&Function.identity/1)
|> Enum.count(&(&1 |> elem(1) |> length() > 1))
|> IO.inspect()
