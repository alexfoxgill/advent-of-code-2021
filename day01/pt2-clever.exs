count =
  File.stream!("day1/input.txt")
  |> Stream.map(&elem(Integer.parse(&1), 0))
  |> Stream.chunk_every(4, 1, :discard)
  |> Enum.count(fn [a, _, _, b] -> a < b end)

IO.puts(count)
