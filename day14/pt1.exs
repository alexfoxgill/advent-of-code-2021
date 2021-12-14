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

defmodule Expansion do
  def apply_once(template, rules) do
    tail =
      template
      |> Stream.zip(Stream.drop(template, 1))
      |> Enum.flat_map(fn {a, b} -> [rules[{a, b}], b] end)

    [hd(template) | tail]
  end
end

{template, rules} = Input.parse(input)

counts =
  Stream.iterate(template, &Expansion.apply_once(&1, rules))
  |> Enum.at(10)
  |> Enum.group_by(& &1)
  |> Enum.map(fn {_, xs} -> Enum.count(xs) end)

(Enum.max(counts) - Enum.min(counts))
|> IO.inspect()
