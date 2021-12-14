input = File.stream!("day14/input.txt")

defmodule Input do
  def parse(stream) do
    template =
      stream
      |> Enum.at(0)
      |> String.trim()
      |> String.to_charlist()

    rules =
      stream
      |> Stream.drop(2)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&parse_rule/1)
      |> Map.new()

    {template, rules}
  end

  defp parse_rule(rule) do
    %{"from" => from, "to" => to} =
      ~r/(?<from>[A-Z]{2}) -> (?<to>[A-Z])/
      |> Regex.named_captures(rule)

    from =
      from
      |> String.to_charlist()
      |> List.to_tuple()

    [to] = String.to_charlist(to)

    {from, to}
  end
end

defmodule Puzzle do
  def solve(template, rules, max_depth) do
    pairs = Map.keys(rules)

    precalc_lookup =
      get_depth_0_map(pairs)
      |> depth_map_stream(pairs, rules)
      |> Enum.fetch!(max_depth)

    initial_map = offset_initial_duplicates(template)

    {min, max} =
      template
      |> Enum.chunk_every(2, 1, :discard)
      |> Stream.map(fn [a, b] -> precalc_lookup[{a, b}] end)
      |> Enum.reduce(initial_map, &merge_count_maps/2)
      |> Stream.map(&elem(&1, 1))
      |> Enum.min_max()

    max - min
  end

  defp merge_count_maps(map_a, map_b) do
    Map.merge(map_a, map_b, fn _, v1, v2 -> v1 + v2 end)
  end

  defp get_depth_0_map(pairs) do
    Map.new(pairs, fn p -> {p, Enum.frequencies(Tuple.to_list(p))} end)
  end

  defp depth_map_stream(depth_0, pairs, rules) do
    Stream.iterate(depth_0, fn lower_cache ->
      Map.new(pairs, fn {a, c} ->
        b = rules[{a, c}]
        a_b = lower_cache[{a, b}]
        b_c = lower_cache[{b, c}]

        a_c =
          merge_count_maps(a_b, b_c)
          |> Map.update(b, 0, &(&1 - 1))

        {{a, c}, a_c}
      end)
    end)
  end

  defp offset_initial_duplicates(template) do
    template
    |> Enum.slice(1..-2)
    |> Enum.reduce(%{}, fn x, count -> Map.update(count, x, 1, &(&1 - 1)) end)
  end
end

{template, rules} = Input.parse(input)

Puzzle.solve(template, rules, 40)
|> IO.inspect()
