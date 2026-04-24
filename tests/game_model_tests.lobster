import testing
import from "../src/"
import game_model

current_test_runner = fn(name:string, t:testf):
    print "testing: {name}"
    t()

run_test("new_game_starts_waiting_with_zero_score"):
    let game = new_game()
    assert game.mode == mode_waiting
    assert game.score == 0
    assert game.high_score == 0
    assert game.bird.y == bird_start_y
    assert game.bird.velocity == 0.0

run_test("flap_starts_playing_and_sets_upward_velocity"):
    let game = new_game()
    flap(game)
    assert game.mode == mode_playing
    assert game.bird.velocity == flap_velocity

run_test("gravity_moves_bird_down_after_time_step"):
    let game = new_game()
    flap(game)
    update(game, 0.5)
    assert game.bird.velocity < flap_velocity
    assert game.bird.y < bird_start_y + flap_velocity * 0.5

run_test("pipe_collision_ends_game"):
    let game = new_game()
    start_playing(game)
    game.pipes = [ pipe { bird_x, game.bird.y + pipe_gap, false } ]
    update(game, 0.016)
    assert game.mode == mode_game_over

run_test("passing_pipe_scores_once"):
    let game = new_game()
    start_playing(game)
    game.pipes = [ pipe { bird_x - pipe_width - bird_radius - 1.0, game.bird.y, false } ]
    update(game, 0.016)
    assert game.score == 1
    update(game, 0.016)
    assert game.score == 1

run_test("reset_preserves_high_score"):
    let game = new_game()
    start_playing(game)
    game.score = 7
    end_game(game)
    reset(game)
    assert game.high_score == 7
    assert game.score == 0
    assert game.mode == mode_waiting

run_test("difficulty_increases_with_score"):
    let early = pipe_speed_for_score(0)
    let late = pipe_speed_for_score(20)
    assert late > early

"the end"
