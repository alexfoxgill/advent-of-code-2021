input = File.stream!("day11/input.txt")

defmodule Input do
  def parse(input) do
    input
    |> Enum.join("")
    |> String.replace("\n", "")
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end
end

defmodule Grid do
  def step(grid) do
    {grid, bump_map} = step_all(grid, 0, fn n, _ -> n + 1 end)
    {grid, _} = step_recurse(grid, bump_map)
    grid
  end

  defp step_recurse(grid, bump_map) when bump_map == %{} do
    {grid, %{}}
  end

  defp step_recurse(grid, bump_map) do
    {grid, bump_map} =
      step_all(grid, 0, fn
        0, _ -> 0
        n, i -> n + Map.get(bump_map, i, 0)
      end)

    step_recurse(grid, bump_map)
  end

  defp get_surrounding(index) do
    width = 10

    case rem(index, width) do
      0 -> [-width, -width + 1, 1, width, width + 1]
      n when n == width - 1 -> [-width - 1, -width, -1, width - 1, width]
      _ -> [-width - 1, -width, -width + 1, -1, 1, width - 1, width, width + 1]
    end
    |> Stream.map(&(index + &1))
    |> Enum.filter(fn x -> x >= 0 && x < width * width end)
  end

  defp step_single(n, index, f) do
    bumped = f.(n, index)

    if bumped > 9 do
      surrounding = get_surrounding(index)
      {0, surrounding}
    else
      {bumped, []}
    end
  end

  defp step_all([head | tail], index, f) do
    {n, bumps} = step_single(head, index, f)

    {bumped_grid, bump_map} = step_all(tail, index + 1, f)

    bump_map = Enum.reduce(bumps, bump_map, fn n, map -> Map.update(map, n, 1, &(&1 + 1)) end)

    {[n | bumped_grid], bump_map}
  end

  defp step_all([], _, _), do: {[], %{}}
end

parsed =
  input
  |> Enum.join("")
  |> String.replace("\n", "")
  |> String.to_charlist()
  |> Enum.map(&(&1 - ?0))

Stream.iterate(parsed, fn grid -> Grid.step(grid) end)
|> Enum.take(101)
|> Enum.map(fn xs -> Enum.count(xs, &(&1 == 0)) end)
|> Enum.sum()
|> IO.inspect()
