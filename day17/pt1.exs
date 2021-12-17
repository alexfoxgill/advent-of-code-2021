input = File.read!("day17/input.txt")

defmodule Puzzle do
  def step_y(pos, vel) do
    pos = pos + vel
    vel = vel - 1
    {pos, vel}
  end

  def max_distance(initial), do: initial * (initial + 1) / 2

  def y_positions(init_vel) do
    Stream.unfold({0, init_vel}, fn {pos, vel} -> {pos, step_y(pos, vel)} end)
  end
end

target_range =
  case input do
    "target area: " <> to_parse -> to_parse
  end
  |> String.split(", ")
  |> Enum.map(fn dir -> String.split(dir, "=") |> Enum.at(1) end)
  |> Enum.map(fn r -> String.split(r, "..") |> Enum.map(&String.to_integer/1) end)
  |> case do
    [[x0, x1], [y0, y1]] -> {x0..x1, y0..y1}
  end

{_, y_target} = target_range

min_y_vel = y_target.first
max_y_vel = -1 * min_y_vel

min_y_vel..max_y_vel
|> Stream.filter(fn vel ->
  last =
    Puzzle.y_positions(vel)
    |> Stream.take_while(&(&1 >= y_target.first))
    |> Enum.reduce(fn x, _ -> x end)

  last <= y_target.last
end)
|> Enum.max()
|> Puzzle.max_distance()
|> IO.inspect()
