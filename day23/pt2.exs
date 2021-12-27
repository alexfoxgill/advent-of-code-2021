defmodule Puzzle do
  @l1 {0, 0}
  @l2 {1, 0}
  @a5 {2, 0}
  @ab {3, 0}
  @b5 {4, 0}
  @bc {5, 0}
  @c5 {6, 0}
  @cd {7, 0}
  @d5 {8, 0}
  @r1 {9, 0}
  @r2 {10, 0}

  @a4 {2, 1}
  @a3 {2, 2}
  @a2 {2, 3}
  @a1 {2, 4}

  @b4 {4, 1}
  @b3 {4, 2}
  @b2 {4, 3}
  @b1 {4, 4}

  @c4 {6, 1}
  @c3 {6, 2}
  @c2 {6, 3}
  @c1 {6, 4}

  @d4 {8, 1}
  @d3 {8, 2}
  @d2 {8, 3}
  @d1 {8, 4}

  @room_a [@a1, @a2, @a3, @a4]
  @room_b [@b1, @b2, @b3, @b4]
  @room_c [@c1, @c2, @c3, @c4]
  @room_d [@d1, @d2, @d3, @d4]

  @rooms MapSet.new(@room_a ++ @room_b ++ @room_c ++ @room_d)

  @hallways MapSet.new([
              @ab,
              @bc,
              @cd,
              @r1,
              @r2,
              @l1,
              @l2
            ])

  @doorways MapSet.new([@a5, @b5, @c5, @d5])

  @all @rooms |> MapSet.union(@hallways) |> MapSet.union(@doorways)

  @goal_state %{
    @a1 => "A",
    @a2 => "A",
    @a3 => "A",
    @a4 => "A",
    @b1 => "B",
    @b2 => "B",
    @b3 => "B",
    @b4 => "B",
    @c1 => "C",
    @c2 => "C",
    @c3 => "C",
    @c4 => "C",
    @d1 => "D",
    @d2 => "D",
    @d3 => "D",
    @d4 => "D"
  }

  def parse(input) do
    lines = String.split(input, "\n")

    for {x, y} <- @all,
        char = lines |> Enum.at(y + 1) |> String.at(x + 1),
        char in ["A", "B", "C", "D"],
        into: %{} do
      {{x, y}, char}
    end
  end

  def get_neighbours({x, y}),
    do:
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.filter(&(&1 in @all))

  def empty?(board, tile), do: board[tile] == nil

  def paths_from(board, tile) do
    paths = paths_from(board, tile, tile, MapSet.new())
    room_path = Enum.find(paths, fn x -> elem(x, 0) in @rooms end)

    if room_path != nil do
      [room_path]
    else
      paths
    end
  end

  def paths_from(board, origin, source, visited) do
    downstream =
      get_neighbours(source)
      |> Enum.filter(&empty?(board, &1))
      |> Enum.reject(&(&1 in visited))
      |> Enum.flat_map(fn tile -> paths_from(board, origin, tile, MapSet.put(visited, source)) end)

    cond do
      origin == source ->
        downstream

      invalid_destination?(board, origin, source) ->
        downstream

      true ->
        cost =
          MapSet.size(visited) *
            case board[origin] do
              "A" -> 1
              "B" -> 10
              "C" -> 100
              "D" -> 1000
            end

        [{source, cost} | downstream]
    end
  end

  def find_room(pos) do
    [@room_a, @room_b, @room_c, @room_d]
    |> Enum.find(&(pos in &1))
  end

  def invalid_destination?(board, origin, destination) do
    room = find_room(destination)

    cond do
      destination in @doorways ->
        true

      origin in @hallways and destination in @hallways ->
        true

      room != nil ->
        cond do
          @goal_state[destination] != board[origin] ->
            true

          lowest_available_slot(board, room) == {:ok, destination} ->
            false

          true ->
            true
        end

      true ->
        false
    end
  end

  def lowest_available_slot(_, []) do
    {:done}
  end

  def lowest_available_slot(board, [a | room]) do
    if board[a] == @goal_state[a] do
      lowest_available_slot(board, room)
    else
      if board[a] == nil do
        {:ok, a}
      else
        {:err}
      end
    end
  end

  def perform_move(board, source, dest) do
    piece = board[source]

    board
    |> Map.put(dest, piece)
    |> Map.delete(source)
  end

  def should_move(board, pos) do
    room = find_room(pos)

    if room == nil do
      true
    else
      case lowest_available_slot(board, room) do
        {:err} -> true
        _ -> false
      end
    end
  end

  def step_board(board) do
    for pos <- Map.keys(board),
        should_move(board, pos),
        {dest, cost} <- paths_from(board, pos),
        board = perform_move(board, pos, dest) do
      {board, cost}
    end
  end

  def step_boards(boards) do
    boards
    |> Enum.reduce(%{}, fn
      {board, assoc}, map when assoc.flag == :halt ->
        existing = Map.get(map, board)

        if existing == nil or existing.cost > assoc.cost do
          Map.put(map, board, assoc)
        else
          map
        end

      {board, assoc}, map ->
        history = [board | assoc.history]

        step_board(board)
        |> Enum.reduce(map, fn {new_board, step_cost}, map ->
          cost = assoc.cost + step_cost
          existing = Map.get(map, new_board)

          if existing == nil or existing.cost > cost do
            Map.put(map, new_board, %{cost: cost, history: history, flag: :cont})
          else
            map
          end
        end)
        |> Map.put(board, %{assoc | flag: :halt})
    end)
  end

  def board_stream(initial) do
    Stream.iterate(%{initial => %{cost: 0, history: [], flag: :cont}}, &step_boards/1)
  end

  def finished?(map) do
    Enum.all?(map, fn {_, x} -> x.flag == :halt end)
  end

  def goal(map) do
    {@goal_state, map[@goal_state]}
  end

  def board_snapshot({board, assoc}) do
    render_board(board)
    IO.inspect({assoc.cost, assoc.flag})
  end

  def render_board(board) do
    IO.puts("\n")

    for y <- 0..4 do
      for x <- 0..11 do
        pos = {x, y}
        Map.get(board, pos, if(pos in @all, do: ".", else: " "))
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def render({board, assoc}) do
    IO.inspect({assoc.cost, assoc.flag})

    [board | assoc.history]
    |> Enum.each(&render_board/1)

    {board, assoc}
  end

  def render_goal(boards) do
    render({@goal_state, Map.get(boards, @goal_state)})
  end

  def solve(start) do
    Puzzle.board_stream(start)
    |> Enum.find(&Puzzle.finished?/1)
  end

  def debug_sample do
    0..22
    |> Enum.map(fn n ->
      File.read!("day23/pt2-input-sample" <> Integer.to_string(n) <> ".txt")
      |> Puzzle.parse()
    end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.each(fn [a, b] ->
      found = Puzzle.step_board(a) |> Enum.find(fn {board, _} -> board == b end)

      if found != nil do
        IO.inspect(elem(found, 1))
      else
        Puzzle.render_board(a)
        Puzzle.render_board(b)
      end
    end)
  end

  def debug_5_6 do
    File.read!("day23/pt2-input-sample5.txt")
    |> Puzzle.parse()
    |> Puzzle.paths_from(@b4)
    |> IO.inspect()
  end

  def execute_sample, do: execute("day23/pt2-input-sample0.txt")
  def execute, do: execute("day23/pt2-input.txt")

  def execute(input) do
    File.read!(input)
    |> Puzzle.parse()
    |> Puzzle.solve()
    |> Puzzle.render_goal()
  end
end

Puzzle.execute()
