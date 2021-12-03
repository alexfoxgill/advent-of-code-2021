input = File.stream!("day3/input.txt")

parsed =
  input
  |> Stream.map(&(String.trim(&1) |> String.to_charlist() |> Enum.map(fn x -> x - 48 end)))

process = fn {a, b} ->
  Stream.iterate(0, &(&1 + 1))
  |> Stream.scan(parsed, fn i, lines ->
    len = Enum.count(lines)
    threshold = len / 2.0
    sum = lines |> Enum.map(&Enum.at(&1, i)) |> Enum.sum()
    selected = if sum >= threshold, do: a, else: b
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

IO.inspect([lsr, csr, lsr * csr])
