input = File.stream!("day18/input.txt")

defmodule Input do
  def parse_line(line) do
    line
    |> String.trim()
    |> String.to_charlist()
    |> parse_num()
    |> elem(0)
  end

  defp parse_num([?[ | rest]) do
    {first, [?, | rest]} = parse_num(rest)
    {second, [?] | rest]} = parse_num(rest)
    {[first, second], rest}
  end

  defp parse_num([n | rest]) when n in ?0..?9, do: {n - ?0, rest}
end

defmodule Snailfish do
  def add(a, b), do: reduce([a, b])

  def magnitude([a, b]), do: 3 * magnitude(a) + 2 * magnitude(b)
  def magnitude(n), do: n

  def reduce(num) do
    num
    |> explode()
    |> split()
  end

  defp explode(num) do
    case explode(num, 0) do
      {:explode_both, _, _, res} -> reduce(res)
      {:explode_right, _, res} -> reduce(res)
      {:explode_left, _, res} -> reduce(res)
      {:exploded, res} -> reduce(res)
      {:ok, x} -> x
    end
  end

  defp explode([a, b], 4) do
    {:explode_both, a, b, 0}
  end

  defp explode([a, b], depth) do
    case explode(a, depth + 1) do
      {:explode_both, l, r, a} ->
        {:explode_left, l, [a, add_left(r, b)]}

      {:explode_left, l, a} ->
        {:explode_left, l, [a, b]}

      {:explode_right, r, a} ->
        {:exploded, [a, add_left(r, b)]}

      {:exploded, a} ->
        {:exploded, [a, b]}

      {:ok, a} ->
        case explode(b, depth + 1) do
          {:explode_both, l, r, b} ->
            {:explode_right, r, [add_right(l, a), b]}

          {:explode_right, r, b} ->
            {:explode_right, r, [a, b]}

          {:explode_left, l, b} ->
            {:exploded, [add_right(l, a), b]}

          {:exploded, b} ->
            {:exploded, [a, b]}

          {:ok, b} ->
            {:ok, [a, b]}
        end
    end
  end

  defp explode(n, _), do: {:ok, n}

  defp add_left(n, [a, b]), do: [add_left(n, a), b]
  defp add_left(n, a), do: n + a
  defp add_right(n, [a, b]), do: [a, add_right(n, b)]
  defp add_right(n, b), do: n + b

  defp split(num) do
    case split_search(num) do
      {:split, num} -> reduce(num)
      {:ok, num} -> num
    end
  end

  defp split_search([a, b]) do
    case split_search(a) do
      {:split, a} ->
        {:split, [a, b]}

      {:ok, a} ->
        {res, b} = split_search(b)
        {res, [a, b]}
    end
  end

  defp split_search(n) when n < 10, do: {:ok, n}

  defp split_search(n) do
    x = n / 2
    {:split, [floor(x), ceil(x)]}
  end
end

numbers = input |> Stream.map(&Input.parse_line/1)

numbers
|> Enum.reduce(&Snailfish.add(&2, &1))
|> Snailfish.magnitude()
|> IO.inspect(charlists: :as_list)
