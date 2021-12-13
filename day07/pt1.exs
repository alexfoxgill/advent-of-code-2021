input = File.stream!("day7/input.txt")

ints =
  input
  |> Stream.flat_map(&String.split(&1, ","))
  |> Stream.map(&String.to_integer/1)
  |> Enum.sort()

median = ints |> Enum.at(round(Enum.count(ints) / 2))

IO.inspect(median)

result = ints |> Enum.reduce(0, fn x, total -> total + abs(x - median) end)

IO.inspect(result)
