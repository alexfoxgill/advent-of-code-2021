# input
{p1, p2} = {6, 10}

rolls = for(a <- 1..3, b <- 1..3, c <- 1..3, do: a + b + c) |> Enum.frequencies()

universes = %{{{p1, 0}, {p2, 0}} => 1}

{w1, w2} =
  Stream.unfold(universes, fn
    universes when universes == %{} ->
      nil

    universes ->
      {won, next} =
        for {{{pos, score}, p2}, count} <- universes, {roll, roll_count} <- rolls do
          pos = rem(pos + roll - 1, 10) + 1
          score = score + pos
          p1 = {pos, score}
          {{p2, p1}, count * roll_count}
        end
        |> Enum.split_with(fn {{_, {_, score}}, _} -> score >= 21 end)

      win_count = Enum.sum(Enum.map(won, &elem(&1, 1)))

      next_map =
        Enum.reduce(next, %{}, fn {key, count}, map ->
          Map.update(map, key, count, &(&1 + count))
        end)

      {win_count, next_map}
  end)
  |> Enum.reduce({0, 0}, fn w, {w1, w2} -> {w2, w1 + w} end)
  |> IO.inspect()
