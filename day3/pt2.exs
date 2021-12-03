input = File.stream!("day3/input.txt")

parsed =
  input
  |> Stream.map(&(String.trim(&1) |> String.to_charlist() |> Enum.map(fn x -> x - 48 end)))

process = fn {a, b} ->
  Stream.iterate(0, &(&1 + 1))
  |> Stream.scan(parsed, fn i, lines ->
    sum = lines |> Stream.map(&(Enum.at(&1, i) * 2 - 1)) |> Enum.sum()
    selected = if sum >= 0, do: a, else: b
    lines |> Enum.filter(&(Enum.at(&1, i) == selected))
  end)
  |> Stream.drop_while(&(Enum.count(&1) > 1))
  |> Enum.at(0)
  |> Enum.at(0)
  |> Enum.join()
  |> String.to_integer(2)
end

lsr = process.({1, 0})
csr = process.({0, 1})

IO.inspect(lsr * csr)
