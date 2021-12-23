input = File.stream!("day22/input.txt")

defmodule Input do
  def parse(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [inst, line] = String.split(line, " ")

    cube =
      String.split(line, ",")
      |> Enum.map(&String.split(&1, "="))
      |> Map.new(fn [axis, range] -> {String.to_atom(axis), parse_range(range)} end)

    {String.to_atom(inst), cube}
  end

  defp parse_range(range) do
    [from, to] = String.split(range, "..") |> Enum.map(&String.to_integer/1)
    from..to
  end
end

defmodule Cuboid do
  def overlap(a, b) do
    x = axis_overlap(a.x, b.x)
    y = axis_overlap(a.y, b.y)
    z = axis_overlap(a.z, b.z)

    if x == nil or y == nil or z == nil, do: nil, else: %{x: x, y: y, z: z}
  end

  def axis_overlap(a, b) do
    cond do
      a.last < b.first -> nil
      b.last < a.first -> nil
      true -> max(a.first, b.first)..min(a.last, b.last)
    end
  end

  def combine(_, [], bs), do: bs

  def combine(:off, _, []), do: []
  def combine(:on, a, []), do: [a]

  def combine(flag, a, [b | bs]) do
    case overlap(a, b) do
      nil -> [b | combine(flag, a, bs)]
      chunk -> remove(chunk, b) ++ combine(flag, a, bs)
    end
  end

  def remove(chunk, cuboid) do
    for x <- split(chunk, cuboid, :x),
        y <- split(chunk, cuboid, :y),
        z <- split(chunk, cuboid, :z),
        piece = %{x: x, y: y, z: z},
        piece != chunk,
        do: piece
  end

  def split(chunk, cuboid, axis) do
    [
      {cuboid[axis].first, chunk[axis].first - 1},
      {chunk[axis].first, chunk[axis].last},
      {chunk[axis].last + 1, cuboid[axis].last}
    ]
    |> Enum.filter(fn {a, b} -> a <= b end)
    |> Enum.map(fn {a, b} -> a..b end)
  end

  def volume(a) do
    (1 + a.x.last - a.x.first) * (1 + a.y.last - a.y.first) * (1 + a.z.last - a.z.first)
  end
end

input
|> Input.parse()
|> Enum.reduce([], fn {flag, a}, bs -> Cuboid.combine(flag, a, bs) end)
|> Enum.map(&Cuboid.volume/1)
|> Enum.sum()
|> IO.inspect()
