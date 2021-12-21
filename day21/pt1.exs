# input
{p1, p2} = {6, 10}

Stream.cycle(1..100)
|> Stream.chunk_every(3)
|> Stream.map(&Enum.sum/1)
|> Stream.with_index(1)
|> Enum.reduce_while({{p1, 0}, {p2, 0}}, fn {rolls, i}, {{pos, score}, p2} ->
  pos = rem(pos + rolls - 1, 10) + 1
  score = score + pos
  if score >= 1000, do: {:halt, {elem(p2, 1), i * 3}}, else: {:cont, {p2, {pos, score}}}
end)
|> Tuple.product()
|> IO.inspect()
