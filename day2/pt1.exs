defmodule Parse do
  def instruction("forward " <> amt), do: {String.to_integer(amt), 0}
  def instruction("up " <> amt), do: {0, -String.to_integer(amt)}
  def instruction("down " <> amt), do: {0, String.to_integer(amt)}
end

{x, y} =
  File.stream!("day2/input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&Parse.instruction/1)
  |> Enum.reduce(fn {a, b}, {c, d} -> {a + c, b + d} end)

IO.puts(x * y)
