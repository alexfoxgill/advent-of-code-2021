input = File.stream!("day20/input.txt")

defmodule Input do
  def parse(input) do
    {decoder, grid} =
      input
      |> Stream.map(fn row ->
        row
        |> String.trim()
        |> String.to_charlist()
        |> Enum.map(fn
          ?. -> 0
          ?# -> 1
        end)
      end)
      |> Enum.split_while(&(&1 != []))

    decoder =
      decoder
      |> List.flatten()
      |> List.to_tuple()

    grid =
      grid
      |> Enum.drop(1)
      |> grid_from_lists(%{}, 0, 0)

    {decoder, grid}
  end

  def grid_from_lists(lists, map, x, y) do
    case lists do
      [[] | []] -> %{cells: map, width: x - 1, height: y, background: 0}
      [[] | lists] -> grid_from_lists(lists, map, 0, y + 1)
      [[a | row] | lists] -> grid_from_lists([row | lists], Map.put(map, {x, y}, a), x + 1, y)
    end
  end
end

defmodule Grid do
  def pad(%{cells: cells, width: width, height: height, background: bg}) do
    cells = Map.new(cells, fn {{x, y}, v} -> {{x + 1, y + 1}, v} end)
    width = width + 2
    height = height + 2

    cells =
      0..width
      |> Enum.reduce(cells, fn x, cells ->
        cells |> Map.put({x, 0}, bg) |> Map.put({x, height}, bg)
      end)

    cells =
      1..(height - 1)
      |> Enum.reduce(cells, fn y, cells ->
        cells |> Map.put({0, y}, bg) |> Map.put({width, y}, bg)
      end)

    %{cells: cells, width: width, height: height, background: bg}
  end

  def step(grid, decoder) do
    grid = grid |> Grid.pad()

    cells =
      grid.cells
      |> Map.new(fn {{x, y}, _} ->
        idx = cells_to_index(grid.cells, grid.background, x, y)
        val = elem(decoder, idx)
        {{x, y}, val}
      end)

    bg = List.duplicate(grid.background, 9) |> Enum.join() |> String.to_integer(2)
    background = elem(decoder, bg)

    %{grid | cells: cells, background: background}
  end

  def cells_to_index(cells, bg, x, y) do
    x_range = (x - 1)..(x + 1)
    y_range = (y - 1)..(y + 1)

    for(y <- y_range, x <- x_range, do: Map.get(cells, {x, y}, bg))
    |> Enum.join()
    |> String.to_integer(2)
  end

  def count_lit_cells(grid) do
    grid.cells
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
    |> IO.inspect()

    grid
  end

  def render(grid) do
    str =
      for y <- 0..grid.height do
        for(x <- 0..grid.width, do: grid.cells[{x, y}])
        |> Enum.map(fn
          1 -> "#"
          0 -> "."
        end)
        |> Enum.join("")
      end
      |> Enum.join("\n")

    IO.puts(str)
    grid
  end
end

{decoder, grid} = Input.parse(input)

Stream.iterate(grid, &Grid.step(&1, decoder))
|> Enum.at(50)
|> Grid.count_lit_cells()
