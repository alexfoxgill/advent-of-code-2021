defmodule Parse do
  def instruction("forward " <> amt), do: {String.to_integer(amt), 0}
  def instruction("up " <> amt), do: {0, -String.to_integer(amt)}
  def instruction("down " <> amt), do: {0, String.to_integer(amt)}
end

{h, _, v} =
  File.stream!("day2/input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&Parse.instruction/1)
  |> Enum.reduce({0, 0, 0}, fn {fwd, aimDelta}, {horiz, aim, vert} ->
    {horiz + fwd, aim + aimDelta, vert + fwd * aim}
  end)

IO.puts(h * v)
