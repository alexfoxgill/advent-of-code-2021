input = File.stream!("day13/input.txt")

defmodule Input do
  def parse(input) do
    {dots, folds} =
      input
      |> Stream.map(&String.trim/1)
      |> Enum.split_while(&(&1 != ""))

    dots =
      dots
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ",")
        {String.to_integer(x), String.to_integer(y)}
      end)

    folds =
      folds
      |> Stream.drop(1)
      |> Enum.map(fn "fold along " <> fold ->
        [axis, value] = String.split(fold, "=")
        {axis, String.to_integer(value)}
      end)

    {dots, folds}
  end
end

defmodule Dots do
  def render(dots, {max_x, max_y}) do
    for y <- 0..max_y do
      for x <- 0..max_x do
        if MapSet.member?(dots, {x, y}), do: "#", else: " "
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end
end

{dots, folds} = Input.parse(input)

folded =
  folds
  |> Enum.reduce(dots, fn fold, dots ->
    folder =
      case fold do
        {"x", fx} -> fn {x, y} -> if x > fx, do: {fx * 2 - x, y}, else: {x, y} end
        {"y", fy} -> fn {x, y} -> if y > fy, do: {x, fy * 2 - y}, else: {x, y} end
      end

    Enum.map(dots, folder)
  end)

maxes = folded |> Enum.reduce({0, 0}, fn {ax, ay}, {bx, by} -> {max(ax, bx), max(ay, by)} end)

Dots.render(MapSet.new(folded), maxes)
|> IO.puts()
