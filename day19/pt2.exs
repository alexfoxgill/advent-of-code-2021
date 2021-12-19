input = File.stream!("day19/input.txt")

defmodule Input do
  def parse(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&parse_line/1)
    |> Stream.chunk_while(
      nil,
      fn
        {:scanner, 0}, nil -> {:cont, {0, MapSet.new()}}
        {:scanner, n}, acc -> {:cont, acc, {n, MapSet.new()}}
        {:beacon, b}, {scanner, beacons} -> {:cont, {scanner, MapSet.put(beacons, b)}}
      end,
      fn x -> {:cont, x, x} end
    )
    |> Map.new()
  end

  def parse_line(line) do
    case Regex.run(~r/--- scanner ([\d]+) ---/, line) do
      [_, scanner] -> {:scanner, String.to_integer(scanner)}
      nil -> {:beacon, String.split(line, ",") |> Enum.map(&String.to_integer/1)}
    end
  end
end

defmodule Puzzle do
  def rotate(xyz, rots) when is_list(rots), do: Enum.reduce(rots, xyz, &rotate(&2, &1))

  def rotate(xyz, {_, 0}), do: xyz
  def rotate([x, y, z], {:yaw, 1}), do: [-z, y, x]
  def rotate([x, y, z], {:yaw, -1}), do: [z, y, -x]
  def rotate([x, y, z], {:pitch, 1}), do: [x, -z, y]
  def rotate([x, y, z], {:pitch, -1}), do: [x, z, -y]
  def rotate([x, y, z], {:roll, 1}), do: [-y, x, z]
  def rotate([x, y, z], {:roll, -1}), do: [y, -x, z]
  def rotate(xyz, {dir, 3}), do: rotate(xyz, {dir, -1})
  def rotate(xyz, {dir, -3}), do: rotate(xyz, {dir, 1})
  def rotate(xyz, {dir, n}) when n in [2, -2], do: xyz |> rotate({dir, 1}) |> rotate({dir, 1})
  def rotate(xyz, {dir, n}) when n > 3 or n < -3, do: rotate(xyz, {dir, rem(n, 4)})

  def invert_rot({dir, n}), do: {dir, -n}
  def invert_rot(rots) when is_list(rots), do: rots |> Enum.reduce([], &[invert_rot(&1) | &2])

  def rotations,
    do: [
      [],
      {:yaw, 1},
      {:yaw, 2},
      {:yaw, -1},
      {:pitch, 1},
      {:pitch, 2},
      {:pitch, -1},
      {:roll, 1},
      {:roll, 2},
      {:roll, -1},
      [{:yaw, 1}, {:roll, 1}],
      [{:yaw, 1}, {:roll, 2}],
      [{:yaw, 1}, {:roll, -1}],
      [{:yaw, -1}, {:roll, 1}],
      [{:yaw, -1}, {:roll, 2}],
      [{:yaw, -1}, {:roll, -1}],
      [{:pitch, 1}, {:roll, 1}],
      [{:pitch, 1}, {:roll, 2}],
      [{:pitch, 1}, {:roll, -1}],
      [{:pitch, -1}, {:roll, 1}],
      [{:pitch, -1}, {:roll, 2}],
      [{:pitch, -1}, {:roll, -1}],
      [{:yaw, 2}, {:roll, 1}],
      [{:yaw, 2}, {:roll, -1}]
    ]

  def pair_diffs(beacons) do
    for(a <- beacons, b <- beacons, a != b, do: [a, b])
    |> Enum.group_by(fn [a, b] -> pos_sub(a, b) end, fn [a, _] -> a end)
  end

  defp pos_sub(a, b), do: Enum.zip_with(a, b, &(&1 - &2))
  defp pos_add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))

  def find_overlap(beacons_a, beacons_b) do
    diffs_a = Puzzle.pair_diffs(beacons_a)

    Puzzle.rotations()
    |> Stream.flat_map(fn rot ->
      diffs_b =
        beacons_b
        |> Stream.map(&rotate(&1, rot))
        |> Puzzle.pair_diffs()

      common_offsets =
        for(
          {diff_a, nodes_a} <- diffs_a,
          b <- Map.get(diffs_b, diff_a, []),
          a <- nodes_a,
          do: pos_sub(a, b)
        )

      case common_offsets do
        [] ->
          []

        diffs ->
          {offset, freq} =
            diffs
            |> Enum.frequencies()
            |> Enum.max_by(&elem(&1, 1))

          if freq >= 132, do: [{rot, offset, freq}], else: []
      end
    end)
    |> Enum.max_by(&elem(&1, 2), fn -> nil end)
  end

  def transform(beacons, rotation, translation) do
    beacons
    |> Stream.map(&rotate(&1, rotation))
    |> Stream.map(&pos_add(&1, translation))
    |> MapSet.new()
  end

  def collapse([a | rest]) do
    [[0, 0, 0] | collapse(a, rest, [])]
  end

  def collapse(_, [], []), do: []
  def collapse(a, [], missed), do: collapse(a, missed, [])

  def collapse(a, [b | rest], missed) do
    case Puzzle.collapse_pair(a, b) do
      nil -> collapse(a, rest, [b | missed])
      {trans, a} -> [trans | collapse(a, rest, missed)]
    end
  end

  def collapse_pair(a, b) do
    case Puzzle.find_overlap(a, b) do
      nil ->
        nil

      {rot, trans, _} ->
        new_b = Puzzle.transform(b, rot, trans)
        {trans, MapSet.union(a, new_b)}
    end
  end

  def manhattan_distance(a, b), do: pos_sub(a, b) |> Enum.map(&abs/1) |> Enum.sum()
end

scanners = Input.parse(input)

scanner_positions = Puzzle.collapse(Enum.map(scanners, &elem(&1, 1)))

for(a <- scanner_positions, b <- scanner_positions, a != b, do: Puzzle.manhattan_distance(a, b))
|> Enum.max()
|> IO.inspect()
