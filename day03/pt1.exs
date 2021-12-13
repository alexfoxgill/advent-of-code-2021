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

getInt = fn bools ->
  bools
  |> Enum.map(fn
    true -> "1"
    false -> "0"
  end)
  |> Enum.join()
  |> String.to_integer(2)
end

gamma = gammaBools |> getInt.()
epsilon = gammaBools |> Enum.map(&not/1) |> getInt.()

IO.puts(gamma * epsilon)
