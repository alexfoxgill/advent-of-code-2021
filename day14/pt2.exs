input = File.stream!("day14/input-sample.txt")

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

    depth_0 =
      pairs
      |> Enum.map(fn pair ->
        {pair,
         case pair do
           {a, a} -> %{a => 2}
           {a, b} -> %{a => 1, b => 1}
         end}
      end)
      |> Map.new()

    cache =
      Stream.iterate(depth_0, fn lower_cache ->
        pairs
        |> Enum.reduce(%{}, fn {a, c}, current_cache ->
          b = rules[{a, c}]
          a_b = lower_cache[{a, b}]
          b_c = lower_cache[{b, c}]

          a_c =
            Map.merge(a_b, b_c, fn _, v1, v2 -> v1 + v2 end)
            |> Map.update(b, 0, &(&1 - 1))

          Map.put(current_cache, {a, c}, a_c)
        end)
      end)
      |> Enum.at(max_depth)

    initial_map =
      template
      |> Enum.slice(1..-2)
      |> Enum.group_by(& &1)
      |> Enum.map(fn {x, xs} -> {x, -1 * Enum.count(xs)} end)
      |> Map.new()

    counts =
      template
      |> Enum.chunk_every(2, 1, :discard)
      |> Stream.map(fn [a, b] -> cache[{a, b}] end)
      |> Enum.reduce(initial_map, &Map.merge(&1, &2, fn _, v1, v2 -> v1 + v2 end))
      |> Enum.map(&{List.to_string([elem(&1, 0)]), elem(&1, 1)})
      |> IO.inspect()
      |> Enum.map(&elem(&1, 1))

    Enum.max(counts) - Enum.min(counts)
  end
end

{template, rules} = Input.parse(input)

Puzzle.solve(template, rules, 10)
|> IO.inspect()
