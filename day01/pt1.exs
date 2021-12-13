count =
  File.stream!("day1/input.txt")
  |> Stream.map(&Integer.parse(&1))
  |> Stream.chunk_every(2, 1, :discard)
  |> Enum.count(fn [a, b] -> a < b end)

IO.puts(count)
