input = File.stream!("day12/input.txt")

defmodule Input do
  def parse(stream) do
    stream
    |> Stream.map(&parse_line/1)
    |> collect()
  end

  defp parse_line(line) do
    regex = ~r/(?<from>[a-z]+)-(?<to>[a-z]+)/i

    Regex.named_captures(regex, line)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), parse_node(v)} end)
    |> Enum.into(%{})
  end

  def parse_node("start"), do: :start
  def parse_node("end"), do: :end

  def parse_node(node) do
    if String.match?(node, ~r/^[a-z]+$/) do
      %{text: node, kind: :small}
    else
      %{text: node, kind: :big}
    end
  end

  defp collect(connections) do
    connections
    |> Enum.reduce(%{}, fn x, map ->
      map
      |> Map.update(x.from, [x.to], &[x.to | &1])
      |> Map.update(x.to, [x.from], &[x.from | &1])
    end)
  end
end

defmodule Graph do
  def explore(graph, node, mode) do
    options = Map.get(graph, node, [])

    {graph, mode} =
      case {node, mode} do
        {:start, _} ->
          {remove(graph, node), mode}

        {%{kind: :small}, :small_repeated} ->
          {remove(graph, node), mode}

        {%{kind: :small}, seen} ->
          if MapSet.member?(seen, node) do
            graph =
              seen
              |> MapSet.to_list()
              |> Enum.reduce(graph, &remove(&2, &1))

            {graph, :small_repeated}
          else
            {graph, MapSet.put(seen, node)}
          end

        _ ->
          {graph, mode}
      end

    options
    |> Stream.map(fn
      :end -> [[:end]]
      x -> Graph.explore(graph, x, mode)
    end)
    |> Stream.flat_map(fn paths -> Stream.map(paths, &[node | &1]) end)
  end

  def remove(graph, node) do
    graph
    |> Stream.filter(fn {n, _} -> n != node end)
    |> Stream.map(fn {n, ns} -> {n, Enum.filter(ns, &(&1 != node))} end)
    |> Enum.into(%{})
  end
end

defmodule GraphPath do
  def render(parts) do
    parts
    |> Enum.map(fn
      :start -> "start"
      :end -> "end"
      n -> n.text
    end)
    |> Enum.join(",")
  end
end

input
|> Input.parse()
|> Graph.explore(:start, MapSet.new())
|> Stream.map(&GraphPath.render/1)
|> Enum.count()
|> IO.inspect()
