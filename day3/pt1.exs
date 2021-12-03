input = File.stream!("day3/input.txt")

gammaBools =
  input
  |> Stream.map(fn line ->
    line
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(fn
      ?1 -> 1
      ?0 -> -1
    end)
  end)
  |> Stream.zip()
  |> Enum.map(&(Tuple.to_list(&1) |> Enum.sum() > 0))

gammaStr = gammaBools |> Enum.map(fn x -> if x, do: "1", else: "0" end)
epsilonStr = gammaBools |> Enum.map(fn x -> if x, do: "0", else: "1" end)

gamma = gammaStr |> Enum.join() |> String.to_integer(2)
epsilon = epsilonStr |> Enum.join() |> String.to_integer(2)

IO.puts(gamma * epsilon)
