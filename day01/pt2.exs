count =
  File.stream!("day1/input.txt")
  |> Stream.map(&elem(Integer.parse(&1), 0))
  |> Stream.chunk_every(3, 1, :discard)
  |> Stream.map(&Enum.sum/1)
  |> Stream.chunk_every(2, 1, :discard)
  |> Enum.count(fn [a, b] -> a < b end)

IO.puts(count)
