input = File.stream!("day3/input.txt")
length = Enum.count(input)

gammaBools =
  input
  |> Stream.map(&(String.trim(&1) |> String.to_charlist() |> Enum.map(fn x -> x - 48 end)))
  |> Stream.zip()
  |> Enum.map(&(Tuple.to_list(&1) |> Enum.sum() > length / 2.0))

gammaStr = gammaBools |> Enum.map(fn x -> if x, do: "1", else: "0" end)
epsilonStr = gammaBools |> Enum.map(fn x -> if x, do: "0", else: "1" end)

gamma = gammaStr |> Enum.join() |> String.to_integer(2)
epsilon = epsilonStr |> Enum.join() |> String.to_integer(2)

IO.puts(gamma * epsilon)
