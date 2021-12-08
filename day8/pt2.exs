input = File.stream!("day8/input.txt")

defmodule Parse do
  def line(str) do
    [observations, input] =
      str
      |> String.trim()
      |> String.split("|")
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(&Enum.map(&1, fn str -> str |> String.to_charlist() |> MapSet.new() end))

    {observations, input}
  end
end

defmodule Deduce do
  def line({obs, inp}) do
    map = deduce_a(%{}, obs) |> deduce_bcdefg(obs)

    inp
    |> Enum.map(&input_to_number(&1, map))
    |> Enum.join()
    |> String.to_integer()
  end

  defp input_to_number(input, map) do
    transformed = input |> MapSet.to_list() |> Enum.map(&Map.get(map, &1)) |> Enum.sort()

    case transformed do
      [?a, ?b, ?c, ?e, ?f, ?g] -> 0
      [?c, ?f] -> 1
      [?a, ?c, ?d, ?e, ?g] -> 2
      [?a, ?c, ?d, ?f, ?g] -> 3
      [?b, ?c, ?d, ?f] -> 4
      [?a, ?b, ?d, ?f, ?g] -> 5
      [?a, ?b, ?d, ?e, ?f, ?g] -> 6
      [?a, ?c, ?f] -> 7
      [?a, ?b, ?c, ?d, ?e, ?f, ?g] -> 8
      [?a, ?b, ?c, ?d, ?f, ?g] -> 9
    end
  end

  defp deduce_a(char_map, obs) do
    [seven] = obs |> just_length(3)
    [one] = obs |> just_length(2)

    [a] = MapSet.difference(seven, one) |> MapSet.to_list()
    Map.put(char_map, a, ?a)
  end

  defp deduce_bcdefg(char_map, obs) do
    fives = obs |> just_length(5) |> count_map()
    sixes = obs |> just_length(6) |> count_map()

    ?a..?g
    |> Enum.reduce(char_map, fn char, map ->
      case {Map.get(fives, char), Map.get(sixes, char)} do
        {1, 3} -> Map.put(map, char, ?b)
        {2, 2} -> Map.put(map, char, ?c)
        {3, 2} -> Map.put(map, char, ?d)
        {1, 2} -> Map.put(map, char, ?e)
        {2, 3} -> Map.put(map, char, ?f)
        {3, 3} -> if Map.has_key?(map, char), do: map, else: Map.put(map, char, ?g)
      end
    end)
  end

  defp just_length(strings, len) do
    strings |> Enum.filter(&(MapSet.size(&1) == len))
  end

  defp count_map(entries) do
    entries |> Enum.reduce(%{}, &add_chars/2)
  end

  defp add_chars(chars, map) do
    chars
    |> Enum.reduce(map, fn char, map -> Map.update(map, char, 1, &(&1 + 1)) end)
  end
end

input
|> Stream.map(&Parse.line/1)
|> Stream.map(&Deduce.line/1)
|> Enum.sum()
|> IO.inspect()

# deduction:
# the difference between the 2- and 3-len inputs maps to 'a'
