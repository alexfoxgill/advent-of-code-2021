input = File.read!("day17/input.txt")

defmodule Puzzle do
  def step_x(pos, vel) do
    pos = pos + vel

    vel =
      case vel do
        x when x > 0 -> x - 1
        x when x < 0 -> x + 1
        0 -> 0
      end

    {pos, vel}
  end

  def step_y(pos, vel) do
    pos = pos + vel
    vel = vel - 1
    {pos, vel}
  end

  def max_distance(initial), do: initial * (initial + 1) / 2

  def xy_positions(init_vel) do
    Stream.unfold({{0, 0}, init_vel}, fn {{x_pos, y_pos}, {x_vel, y_vel}} ->
      {x_pos, x_vel} = step_x(x_pos, x_vel)
      {y_pos, y_vel} = step_y(y_pos, y_vel)
      pos = {x_pos, y_pos}
      {pos, {pos, {x_vel, y_vel}}}
    end)
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

{x_target, y_target} = target_range

min_y_vel = y_target.first
max_y_vel = -1 * min_y_vel
y_vel_range = min_y_vel..max_y_vel

min_x_vel =
  Stream.iterate(1, &(&1 + 1))
  |> Stream.drop_while(&(Puzzle.max_distance(&1) < x_target.first))
  |> Enum.at(0)

x_vel_range = min_x_vel..(x_target.last + 1)

for(
  y <- y_vel_range,
  x <- x_vel_range,
  do: {x, y}
)
|> Stream.filter(fn vel ->
  {x, y} =
    Puzzle.xy_positions(vel)
    |> Stream.take_while(fn {x, y} -> x <= x_target.last and y >= y_target.first end)
    |> Enum.reduce({0, 0}, fn x, _ -> x end)

  x >= x_target.first && y <= y_target.last
end)
|> Enum.count()
|> IO.inspect()
