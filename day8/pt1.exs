input = File.stream!("day8/input.txt")

defmodule Parse do
  def line(str) do
    [observations, input] =
      str
      |> String.trim()
      |> String.split("|")
      |> Enum.map(&String.split(&1, " ", trim: true))

    {observations, input}
  end
end

defmodule Deduce do
  def line({_, inp}) do
    inp
    |> Enum.map(&String.length/1)
    |> Enum.count(&Enum.member?([2, 3, 4, 7], &1))
  end
end

input
|> Stream.map(&Parse.line/1)
|> Stream.map(&Deduce.line/1)
|> Enum.sum()
|> IO.inspect()
