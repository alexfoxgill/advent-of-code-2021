input = File.stream!("day9/input.txt")

defmodule Grid do
  def parse(raw) do
    raw
    |> Stream.map(fn line ->
      line |> String.trim() |> String.to_charlist() |> Enum.map(&(&1 - 48))
    end)
  end

  def pad_tens(stream) do
    width =
      stream
      |> Stream.take(1)
      |> Enum.at(0)
      |> length()

    padding = List.duplicate(10, width + 2)

    [
      [padding],
      stream |> Stream.map(fn row -> [[10], row, [10]] |> Enum.concat() end),
      [padding]
    ]
    |> Stream.concat()
  end

  def neighbours(padded_stream) do
    padded_stream
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.flat_map(fn [above, current, below] ->
      [
        above |> Stream.drop(1),
        current |> Stream.chunk_every(3, 1, :discard),
        below |> Stream.drop(1)
      ]
      |> Stream.zip()
      |> Stream.map(fn {u, [l, x, r], d} -> {x, [u, r, d, l]} end)
    end)
  end

  def is_lowest({point, neighbours}) do
    Enum.all?(neighbours, &(&1 > point))
  end
end

input
|> Grid.parse()
|> Grid.pad_tens()
|> Grid.neighbours()
|> Stream.filter(&Grid.is_lowest/1)
|> Stream.map(fn {x, _} -> x + 1 end)
|> Enum.sum()
|> IO.inspect()
