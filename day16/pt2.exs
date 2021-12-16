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

  def parse_bin_list(bits) do
    Enum.join(bits) |> Integer.parse(2) |> elem(0)
  end

  defp parse_packet(rest) do
    {v, rest} = Enum.split(rest, 3)
    v = parse_bin_list(v)
    {t, rest} = Enum.split(rest, 3)

    case parse_bin_list(t) do
      4 ->
        {literal, rest} = parse_literal(rest)

        packet = %{
          version: v,
          type: :literal,
          literal: literal
        }

        {packet, rest}

      opcode ->
        {ops, rest} = parse_operator(rest)

        packet = %{
          version: v,
          type: :operator,
          opcode: opcode,
          ops: ops
        }

        {packet, rest}
    end
  end

  defp parse_literal(rest) do
    {bin_list, rest} = parse_literal_chunk(rest)
    {parse_bin_list(bin_list), rest}
  end

  defp parse_literal_chunk([1 | rest]) do
    {part, rest} = Enum.split(rest, 4)
    {bin_list, rest} = parse_literal_chunk(rest)
    {part ++ bin_list, rest}
  end

  defp parse_literal_chunk([0 | rest]) do
    Enum.split(rest, 4)
  end

  defp parse_operator([0 | rest]) do
    {len_bin, rest} = Enum.split(rest, 15)
    len = parse_bin_list(len_bin)
    {sub_packets_bin, rest} = Enum.split(rest, len)

    sub_packets =
      Stream.unfold(sub_packets_bin, fn
        [] -> nil
        bin -> parse_packet(bin)
      end)
      |> Enum.to_list()

    {sub_packets, rest}
  end

  defp parse_operator([1 | rest]) do
    {num_packets_bin, rest} = Enum.split(rest, 11)
    num_sub_packets = parse_bin_list(num_packets_bin)
    parse_sub_packets(num_sub_packets, rest)
  end

  defp parse_sub_packets(0, rest), do: {[], rest}

  defp parse_sub_packets(n, rest) do
    {first_packet, rest} = parse_packet(rest)
    {other_packets, rest} = parse_sub_packets(n - 1, rest)
    {[first_packet | other_packets], rest}
  end
end

defmodule Puzzle do
  def sum_versions(%{type: :operator, version: v, ops: ops}) do
    v + Enum.sum(Enum.map(ops, &sum_versions/1))
  end

  def sum_versions(%{type: :literal, version: v}), do: v

  def eval(%{type: literal, literal: v}), do: v

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
