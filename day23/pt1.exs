defmodule Puzzle do
  @l1 {0, 0}
  @l2 {1, 0}
  @a3 {2, 0}
  @ab {3, 0}
  @b3 {4, 0}
  @bc {5, 0}
  @c3 {6, 0}
  @cd {7, 0}
  @d3 {8, 0}
  @r1 {9, 0}
  @r2 {10, 0}

  @a2 {2, 1}
  @a1 {2, 2}

  @b2 {4, 1}
  @b1 {4, 2}

  @c2 {6, 1}
  @c1 {6, 2}

  @d2 {8, 1}
  @d1 {8, 2}

  @rooms MapSet.new([
           @a1,
           @a2,
           @b1,
           @b2,
           @c1,
           @c2,
           @d1,
           @d2
         ])

  @same_room MapSet.new([{@a1, @a2}, {@b1, @b2}, {@c1, @c2}, {@d1, @d2}])

  @hallways MapSet.new([
              @ab,
              @bc,
              @cd,
              @r1,
              @r2,
              @l1,
              @l2
            ])

  @doorways MapSet.new([@a3, @b3, @c3, @d3])

  @all @rooms |> MapSet.union(@hallways) |> MapSet.union(@doorways)

  @goal_state %{
    @a1 => "A",
    @a2 => "A",
    @b1 => "B",
    @b2 => "B",
    @c1 => "C",
    @c2 => "C",
    @d1 => "D",
    @d2 => "D"
  }

  def parse(input) do
    for {x, y} <- @all,
        pos = 14 * (y + 1) + (x + 1),
        char = String.at(input, pos),
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

  def invalid_destination?(board, origin, destination) do
    in_doorway = destination in @doorways
    hallway_to_hallway = origin in @hallways and destination in @hallways
    incorrect_room = destination in @rooms and @goal_state[destination] != board[origin]
    invalid_roommate = destination in @rooms and invalid_roommate?(board, destination)
    is_same = {origin, destination} in @same_room

    in_doorway or
      hallway_to_hallway or
      incorrect_room or
      invalid_roommate or
      is_same
  end

  def invalid_roommate?(board, room) do
    case room do
      @a2 -> board[@a1] != "A"
      @b2 -> board[@b1] != "B"
      @c2 -> board[@c1] != "C"
      @d2 -> board[@d1] != "D"
      _ -> false
    end
  end

  def perform_move(board, source, dest) do
    piece = board[source]

    board
    |> Map.put(dest, piece)
    |> Map.delete(source)
  end

  def should_move(@a1, "A"), do: false
  def should_move(@b1, "B"), do: false
  def should_move(@c1, "C"), do: false
  def should_move(@d1, "D"), do: false
  def should_move(_, _), do: true

  def step_board(board) do
    for {pos, piece} <- board,
        should_move(pos, piece),
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

    for y <- 0..2 do
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
end

"day23/input.txt"
|> File.read!()
|> Puzzle.parse()
|> Puzzle.solve()
|> Puzzle.render_goal()
