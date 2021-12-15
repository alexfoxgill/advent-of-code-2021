input = File.stream!("day15/input.txt")

defmodule Input do
  def parse(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn xs -> xs |> String.to_charlist() |> Enum.map(&(&1 - ?0)) end)
    |> Stream.map(&to_indexed_map/1)
    |> to_indexed_map()
  end

  defp to_indexed_map(list) do
    list
    |> Enum.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end
end

defmodule Grid do
  def generate_part_2(grid) do
    grid_height = map_size(grid)
    grid_width = map_size(grid[0])

    for y_mult <- 0..4,
        y <- 0..(grid_height - 1),
        into: %{} do
      y_pos = y + y_mult * grid_height

      row =
        for x_mult <- 0..4, x <- 0..(grid_width - 1), into: %{} do
          x_pos = x + x_mult * grid_width
          value = grid[y][x] + x_mult + y_mult
          value = if value > 9, do: value - 9, else: value
          {x_pos, value}
        end

      {y_pos, row}
    end
  end

  def shortest_path(grid, origin, target) do
    seen = %{}
    known_distances = %{origin => 0}
    shortest_path(grid, target, seen, known_distances)
  end

  defp shortest_path(grid, target, seen, known_distances) do
    {nearest, distance} = Enum.min_by(known_distances, &elem(&1, 1))

    if nearest == target do
      distance
    else
      seen = Map.put(seen, nearest, distance)

      known_distances = Map.delete(known_distances, nearest)

      known_distances =
        adjacent(grid, nearest)
        |> Stream.reject(fn pos -> Map.has_key?(seen, pos) end)
        |> Enum.reduce(known_distances, fn pos, kd ->
          value = distance + at(grid, pos)
          Map.update(kd, pos, value, &min(&1, value))
        end)

      shortest_path(grid, target, seen, known_distances)
    end
  end

  defp at(grid, {x, y}), do: grid[y][x]

  defp adjacent(grid, {x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Stream.filter(fn pos -> at(grid, pos) != nil end)
  end
end

grid = Input.parse(input) |> Grid.generate_part_2()

origin = {0, 0}
target_y = Enum.max(Map.keys(grid))
target_x = Enum.max(Map.keys(grid[target_y]))
target = {target_x, target_y} |> IO.inspect()

Grid.shortest_path(grid, origin, target)
|> IO.inspect()
