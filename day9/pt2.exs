input = File.stream!("day9/input-sample.txt")

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

  def with_flow(grid) do
    Stream.map(grid.value_map, fn {y, row} ->
      Stream.map(row, fn {x, value} ->
        flow =
          neighbours(grid, {x, y})
          |> Map.put(:trough, value)
          |> Enum.min_by(fn {_, val} -> val end)
          |> elem(0)

        %{
          value: value,
          flow: flow
        }
      end)
    end)
    |> from_lists()
  end

  def find_troughs(grid) do
    Stream.flat_map(grid.value_map, fn {y, row} ->
      Stream.map(row, fn {x, value} ->
        Map.put(value, :xy, {x, y})
      end)
    end)
    |> Stream.filter(fn item -> item.flow == :trough end)
  end

  def neighbours(grid, from) do
    [:north, :south, :west, :east]
    |> Enum.map(fn dir -> {dir, get(grid, go(from, dir))} end)
    |> Enum.filter(fn {_, val} -> val != nil end)
    |> Enum.into(%{})
  end

  def go({x, y}, dir) do
    case dir do
      :north -> {x, y - 1}
      :south -> {x, y + 1}
      :west -> {x - 1, y}
      :east -> {x + 1, y}
    end
  end

  def trace_inflow_size(grid, pos) do
    1 +
      (grid
       |> neighbours(pos)
       |> Enum.map(fn
         {_, %{value: 9}} -> 0
         {:north, %{flow: :south}} -> trace_inflow_size(grid, go(pos, :north))
         {:south, %{flow: :north}} -> trace_inflow_size(grid, go(pos, :south))
         {:west, %{flow: :east}} -> trace_inflow_size(grid, go(pos, :west))
         {:east, %{flow: :west}} -> trace_inflow_size(grid, go(pos, :east))
         _ -> 0
       end)
       |> Enum.sum())
  end
end

grid =
  input
  |> Input.parse()
  |> Grid.from_lists()
  |> Grid.with_flow()

troughs =
  grid
  |> Grid.find_troughs()
  |> Enum.map(&Grid.trace_inflow_size(grid, &1.xy))
  |> Enum.to_list()
  |> Enum.sort(:desc)
  |> Enum.take(3)
  |> Enum.product()
  |> IO.inspect()
