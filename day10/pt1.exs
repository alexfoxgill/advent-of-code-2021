input = File.stream!("day10/input.txt")

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
  {:err, _, ?)} -> 3
  {:err, _, ?]} -> 57
  {:err, _, ?}} -> 1197
  {:err, _, ?>} -> 25137
  _ -> 0
end)
|> Enum.sum()
|> IO.inspect()
