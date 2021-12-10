input = File.stream!("day9/input.txt")

defmodule Input do
  def parse(raw) do
    raw
    |> Stream.map(fn line ->
      line
      |> String.trim()
      |> String.to_charlist()
      |> Enum.map(&(&1 - 48))
    end)
  end
end

defmodule Grid do
  defp to_indexed_map(list) do
    list
    |> Enum.with_index()
    |> Enum.map(fn {x, i} -> {i, x} end)
    |> Enum.into(%{})
  end

  def from_lists(lists) do
    value_map =
      lists
      |> Stream.map(&to_indexed_map/1)
      |> to_indexed_map()

    height = Enum.count(value_map)
    width = Enum.count(value_map[0])

    %{
      height: height,
      width: width,
      value_map: value_map
    }
  end

  def get(grid, {x, y}) do
    grid.value_map[y][x]
  end

  def find_troughs(grid) do
    Stream.flat_map(grid.value_map, fn {y, row} ->
      Stream.flat_map(row, fn {x, value} ->
        is_trough =
          neighbours(grid, {x, y})
          |> Enum.all?(&(&1.value > value))

        if is_trough, do: [{x, y}], else: []
      end)
    end)
  end

  def neighbours(grid, from) do
    [:north, :south, :west, :east]
    |> Enum.map(&go(from, &1))
    |> Enum.map(fn xy -> %{xy: xy, value: get(grid, xy)} end)
    |> Enum.filter(&(&1.value != nil))
  end

  def go({x, y}, dir) do
    case dir do
      :north -> {x, y - 1}
      :south -> {x, y + 1}
      :west -> {x - 1, y}
      :east -> {x + 1, y}
    end
  end

  def basin_size(grid, start) do
    search_basin(grid, start, MapSet.new([start]))
    |> MapSet.size()
  end

  defp search_basin(grid, current, found) do
    grid
    |> neighbours(current)
    |> Enum.reject(fn
      %{value: 9} -> true
      %{xy: xy} -> MapSet.member?(found, xy)
    end)
    |> Enum.reduce(found, fn %{xy: xy}, found -> search_basin(grid, xy, MapSet.put(found, xy)) end)
  end
end

grid =
  input
  |> Input.parse()
  |> Grid.from_lists()

grid
|> Grid.find_troughs()
|> Enum.to_list()
|> Enum.map(&Grid.basin_size(grid, &1))
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.product()
|> IO.inspect()
