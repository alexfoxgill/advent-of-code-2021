input = File.stream!("day4/input.txt")

defmodule Input do
  def parse(stream) do
    draws =
      stream
      |> Enum.at(0)
      |> String.split(",")
      |> Stream.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    grids =
      stream
      |> Stream.drop(1)
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_every(6)
      |> Stream.map(&parse_grid/1)

    {draws, grids}
  end

  defp parse_grid(chunk) do
    chunk
    |> Enum.join(" ")
    |> String.split(" ", trim: true)
    |> Enum.map(fn x -> %{marked: false, value: String.to_integer(x)} end)
  end
end

defmodule Grid do
  def mark(grid, value) do
    grid
    |> Enum.map(fn
      x when x.value == value -> %{x | marked: true}
      x -> x
    end)
  end

  def check?(grid) do
    marked = Enum.map(grid, & &1.marked) |> Enum.chunk_every(5)

    row_full = marked |> Enum.any?(&Enum.all?/1)

    col_full =
      marked
      |> Enum.zip()
      |> Stream.map(fn col -> col |> Tuple.to_list() end)
      |> Enum.any?(&Enum.all?/1)

    row_full or col_full
  end

  def score(grid) do
    Stream.reject(grid, fn x -> x.marked end)
    |> Stream.map(& &1.value)
    |> Enum.sum()
  end
end

{draws, grids} = input |> Input.parse()

draws
|> Stream.scan({:cont, grids}, fn draw, {_, grids} ->
  marked_grids = grids |> Enum.map(&Grid.mark(&1, draw))
  checked_grids = marked_grids |> Enum.reject(&Grid.check?/1)

  case {marked_grids, checked_grids} do
    {[final], []} -> {:ok, Grid.score(final) * draw}
    _ -> {:cont, checked_grids}
  end
end)
|> Stream.drop_while(&(elem(&1, 0) == :cont))
|> Enum.at(0)
|> IO.inspect()
