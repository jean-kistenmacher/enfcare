defmodule App.CourseGameTest do
  use ExUnit.Case, async: true

  alias App.CourseGame

  defp right_answer(%{kind: :text} = step), do: step.expected
  defp right_answer(step), do: step.answer

  defp wrong_answer(%{kind: :text}), do: "não sei"

  defp wrong_answer(step) do
    {key, _} = Enum.find(step.options, fn {key, _} -> key != step.answer end)
    key
  end

  defp play(state, wrong? \\ fn _ -> false end) do
    cond do
      CourseGame.finished?(state) ->
        state

      state["brief"] ->
        state |> CourseGame.start() |> play(wrong?)

      state["feedback"] ->
        state |> CourseGame.continue() |> play(wrong?)

      true ->
        step = CourseGame.current(state)
        answer = if wrong?.(step), do: wrong_answer(step), else: right_answer(step)
        state |> CourseGame.submit(answer) |> play(wrong?)
    end
  end

  defp to_phase(phase) do
    Enum.reduce_while(1..100, CourseGame.new_state(), fn _, state ->
      state = state |> CourseGame.start() |> CourseGame.continue()

      if CourseGame.current(state).phase == phase,
        do: {:halt, CourseGame.start(state)},
        else: {:cont, CourseGame.submit(state, right_answer(CourseGame.current(state)))}
    end)
  end

  test "has 21 steps and 340 possible points" do
    assert length(CourseGame.steps()) == 21
    assert length(CourseGame.scored_steps()) == 11
    assert CourseGame.max_points() == 340
  end

  test "the reference answer of every phase 1 item is accepted" do
    for %{kind: :text} = step <- CourseGame.steps() do
      state = to_phase("f1") |> Map.put("step", Enum.find_index(CourseGame.steps(), &(&1.id == step.id)))
      assert %{"feedback" => %{"correct" => true}} = CourseGame.submit(state, step.expected)
    end
  end

  test "a perfect run is Especialista em RAM with 100%" do
    state = play(CourseGame.new_state())
    summary = CourseGame.summary(state)

    assert state["status"] == "finished"
    assert summary.points == 340
    assert summary.level.id == "especialista-ram"
    assert summary.effectiveness == 100
    assert summary.safety == 100
    assert summary.pretest == %{correct: 10, total: 10}
    assert summary.review == []
    assert %{status: "finished", points: 340, level: "especialista-ram"} = CourseGame.attempt_attrs(state)
  end

  test "the pre-test is neither scored nor answered with feedback" do
    state = CourseGame.new_state() |> CourseGame.start()
    state = CourseGame.submit(state, "c")

    assert state["points"] == 0
    assert state["feedback"] == nil
    assert state["step"] == 1
    assert state["pretest"] == %{"pre-1" => "c"}
  end

  test "an unknown option is ignored" do
    state = CourseGame.new_state() |> CourseGame.start()
    assert CourseGame.submit(state, "z") == state
  end

  test "moving to a new phase shows its briefing first" do
    state = to_phase("f1") |> Map.put("step", 9)
    state = CourseGame.submit(state, "a")

    assert state["step"] == 10
    assert state["brief"] == true
    assert CourseGame.submit(state, "a") == state
  end

  test "text answers are matched by keywords ignoring case and accents" do
    state = to_phase("f1")

    assert %{"feedback" => %{"correct" => true}} =
             CourseGame.submit(state, "COLETAR a hemocultura ANTES da 1ª dose")

    assert %{"feedback" => %{"correct" => false}} =
             CourseGame.submit(state, "Administrar o antibiótico imediatamente")

    assert CourseGame.submit(state, "   ") == state
  end

  test "consecutive hits give a bonus and a miss resets the streak" do
    state = to_phase("f1")
    state = state |> CourseGame.submit("coletar antes") |> CourseGame.continue()
    assert state["points"] == 10

    state = state |> CourseGame.submit("eficácia") |> CourseGame.continue()
    assert state["points"] == 10 + 10 + 5
    assert state["streak"] == 2

    state = state |> CourseGame.submit("não sei") |> CourseGame.continue()
    assert state["streak"] == 0
    assert state["lives"] == 3
  end

  test "asking for a hint costs points and is only possible once" do
    state = to_phase("f1")
    refute state["hint"]

    state = state |> CourseGame.hint() |> CourseGame.hint()
    assert state["hint"]

    state = CourseGame.submit(state, "coletar antes")
    assert state["points"] == 6
  end

  test "hints are not available in the pre-test" do
    state = CourseGame.new_state() |> CourseGame.start()
    assert CourseGame.hint(state) == state
  end

  test "mistakes in phase 2 and 3 cost lives and the third ends the game" do
    state = play(CourseGame.new_state(), &(&1.phase in ["f2", "f3"]))

    assert state["status"] == "game_over"
    assert state["lives"] == 0
    assert length(state["log"]) == 5 + 3

    summary = CourseGame.summary(state)
    assert summary.game_over?
    assert summary.level.id != "especialista-ram"
    assert Enum.any?(summary.review, &(not &1.answered?))
    assert %{status: "game_over", level: _} = CourseGame.attempt_attrs(state)

    assert CourseGame.submit(state, "b") == state
  end

  test "game over keeps the attempt as playing until the feedback is read" do
    state = to_phase("f2") |> Map.put("lives", 1)
    step = CourseGame.current(state)
    state = CourseGame.submit(state, wrong_answer(step))

    assert state["status"] == "game_over"
    refute CourseGame.finished?(state)
    assert %{status: "playing"} = CourseGame.attempt_attrs(state)

    state = CourseGame.continue(state)
    assert CourseGame.finished?(state)
    assert %{status: "game_over"} = CourseGame.attempt_attrs(state)
  end

  test "mistakes in phase 1 do not cost lives" do
    state = play(CourseGame.new_state(), &(&1.phase == "f1"))

    assert state["lives"] == 3
    assert state["status"] == "finished"
    assert CourseGame.summary(state).level.id != "especialista-ram"
  end

  test "the state survives a JSON round trip" do
    state = to_phase("f2") |> CourseGame.submit("b")
    assert state |> Jason.encode!() |> Jason.decode!() |> CourseGame.load_state() == state
  end
end
