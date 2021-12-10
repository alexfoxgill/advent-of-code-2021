input = File.stream!("day10/input.txt")

median = fn xs -> xs |> Enum.sort() |> Enum.at(round(length(xs) / 2) - 1) end

input
|> Stream.map(fn line ->
  line
  |> String.trim()
  |> String.to_charlist()
  |> Enum.reduce({:ok, 0, []}, fn
    _, {:err, n, unmatched} ->
      {:err, n, unmatched}

    open, {_, n, stack} when open in [?(, ?{, ?[, ?<] ->
      {:ok, n + 1, [open | stack]}

    close, {_, n, [open | rest]} when {open, close} in [{?(, ?)}, {?{, ?}}, {?[, ?]}, {?<, ?>}] ->
      {:ok, n + 1, rest}

    unmatched, {_, n, _} ->
      {:err, n, unmatched}
  end)
end)
|> Stream.map(fn
  {:ok, _, stack} ->
    stack
    |> Enum.reduce(0, fn
      ?(, acc -> acc * 5 + 1
      ?[, acc -> acc * 5 + 2
      ?{, acc -> acc * 5 + 3
      ?<, acc -> acc * 5 + 4
    end)

  _ ->
    0
end)
|> Stream.filter(&(&1 > 0))
|> Enum.to_list()
|> median.()
|> IO.inspect()
