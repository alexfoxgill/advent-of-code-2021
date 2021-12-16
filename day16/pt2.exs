input = File.read!("day16/input.txt")

defmodule Input do
  def parse(hex) do
    hex
    |> String.split("", trim: true)
    |> Enum.flat_map(&hex_to_binary/1)
    |> parse_packet()
  end

  defp hex_to_binary(hex_char) do
    hex_char
    |> Integer.parse(16)
    |> elem(0)
    |> Integer.digits(2)
    |> pad_zero()
  end

  defp pad_zero([a, b, c, d]), do: [a, b, c, d]
  defp pad_zero(rest), do: pad_zero([0 | rest])

  defp parse_bin_list(bits) do
    Enum.join(bits) |> Integer.parse(2) |> elem(0)
  end

  defp {a, rest} ~> f, do: {f.(a), rest}
  defp {a, rest} ~>> f, do: f.(a, rest)

  defp {a, rest} <~> f do
    {b, rest} = f.(rest)
    {{a, b}, rest}
  end

  defp parse_packet(rest) do
    {{v, t}, rest} =
      Enum.split(rest, 3)
      ~> (&parse_bin_list/1)
      <~> fn rest -> Enum.split(rest, 3) ~> (&parse_bin_list/1) end

    case t do
      4 ->
        parse_literal(rest)
        ~> (&%{
              version: v,
              type: :literal,
              literal: &1
            })

      opcode ->
        parse_operator(rest)
        ~> (&%{
              version: v,
              type: :operator,
              opcode: opcode,
              ops: &1
            })
    end
  end

  defp parse_literal(rest) do
    parse_literal_chunk(rest) ~> (&parse_bin_list/1)
  end

  defp parse_literal_chunk([1 | rest]) do
    Enum.split(rest, 4)
    <~> (&parse_literal_chunk/1)
    ~> fn {a, b} -> a ++ b end
  end

  defp parse_literal_chunk([0 | rest]) do
    Enum.split(rest, 4)
  end

  defp parse_operator([0 | rest]) do
    Enum.split(rest, 15)
    ~> (&parse_bin_list/1)
    ~>> (&Enum.split(&2, &1))
    ~> (&Stream.unfold(&1, fn
          [] -> nil
          bin -> parse_packet(bin)
        end))
    ~> (&Enum.to_list/1)
  end

  defp parse_operator([1 | rest]) do
    Enum.split(rest, 11)
    ~> (&parse_bin_list/1)
    ~>> (&parse_sub_packets/2)
  end

  defp parse_sub_packets(0, rest), do: {[], rest}

  defp parse_sub_packets(n, rest) do
    parse_packet(rest)
    <~> (&parse_sub_packets(n - 1, &1))
    ~> fn {a, b} -> [a | b] end
  end
end

defmodule Puzzle do
  def sum_versions(%{type: :operator, version: v, ops: ops}) do
    v + Enum.sum(Enum.map(ops, &sum_versions/1))
  end

  def sum_versions(%{type: :literal, version: v}), do: v

  def eval(%{literal: lit}), do: lit
  def eval(%{opcode: op, ops: ops}), do: ops |> Enum.map(&eval/1) |> apply_op(op)

  def apply_op(xs, 0), do: Enum.sum(xs)
  def apply_op(xs, 1), do: Enum.product(xs)
  def apply_op(xs, 2), do: Enum.min(xs)
  def apply_op(xs, 3), do: Enum.max(xs)
  def apply_op([a, b], 5), do: if(a > b, do: 1, else: 0)
  def apply_op([a, b], 6), do: if(a < b, do: 1, else: 0)
  def apply_op([a, b], 7), do: if(a == b, do: 1, else: 0)
end

Input.parse(input)
|> elem(0)
|> Puzzle.eval()
|> IO.inspect()
