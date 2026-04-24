import std

let screen_width = 480.0
let screen_height = 720.0
let ground_y = 84.0
let bird_x = 130.0
let bird_start_y = 360.0
let bird_radius = 22.0
let gravity = -1550.0
let flap_velocity = 470.0
let pipe_width = 86.0
let pipe_gap = 178.0
let pipe_spacing = 255.0
let pipe_spawn_x = screen_width + pipe_width
let pipe_remove_x = -pipe_width
let mode_waiting = 0
let mode_playing = 1
let mode_game_over = 2

struct bird:
    y:float
    velocity:float
    tilt:float

class pipe:
    x:float
    gap_y:float
    scored:bool

class game:
    mode:int
    bird:bird
    pipes:[pipe]
    score:int
    high_score:int
    elapsed:float
    next_pipe_x:float
    seed:int
    blink_timer:float

def make_bird(): return bird { bird_start_y, 0.0, 0.0 }

def new_game():
    return game {
        mode_waiting,
        make_bird(),
        []::pipe,
        0,
        0,
        0.0,
        pipe_spawn_x,
        17,
        0.0,
    }

def pipe_speed_for_score(score:int):
    return 165.0 + min(score, 30) * 4.0

def next_seed(seed:int):
    return (seed * 1103515245 + 12345) & 0x7fffffff

def next_gap_y(seed:int):
    let normalized = div(seed % 1000, 1000)
    return 205.0 + normalized * 270.0

def spawn_pipe(g::game):
    g.seed = next_seed(g.seed)
    g.pipes.push(pipe { pipe_spawn_x, next_gap_y(g.seed), false })
    g.next_pipe_x = pipe_spawn_x + pipe_spacing

def start_playing(g::game):
    g.mode = mode_playing
    g.bird.velocity = flap_velocity
    if g.pipes.length == 0:
        spawn_pipe(g)

def flap(g::game):
    if g.mode == mode_waiting:
        start_playing(g)
    elif g.mode == mode_playing:
        g.bird.velocity = flap_velocity

def end_game(g::game):
    if g.mode != mode_game_over:
        g.mode = mode_game_over
        g.high_score = max(g.high_score, g.score)
        g.blink_timer = 0.0

def reset(g::game):
    let previous_high = g.high_score
    g.mode = mode_waiting
    g.bird = make_bird()
    g.pipes = []::pipe
    g.score = 0
    g.high_score = previous_high
    g.elapsed = 0.0
    g.next_pipe_x = pipe_spawn_x
    g.blink_timer = 0.0

def bird_hits_pipe(b::bird, p::pipe):
    let horizontal = abs(bird_x - p.x) < bird_radius + pipe_width / 2.0
    let vertical = abs(b.y - p.gap_y) > pipe_gap / 2.0 - bird_radius
    return horizontal and vertical

def bird_out_of_bounds(b::bird):
    return b.y - bird_radius <= ground_y or b.y + bird_radius >= screen_height

def update_pipe_scores(g::game):
    for(g.pipes) p:
        if not p.scored and p.x + pipe_width / 2.0 < bird_x - bird_radius:
            p.scored = true
            g.score++
            g.high_score = max(g.high_score, g.score)

def update(g::game, dt:float):
    if g.mode == mode_waiting:
        g.blink_timer += dt
        return
    if g.mode == mode_game_over:
        g.blink_timer += dt
        return

    g.elapsed += dt
    g.bird.velocity += gravity * dt
    g.bird.y += g.bird.velocity * dt
    g.bird.tilt = clamp(g.bird.velocity / 600.0, -0.8, 0.6)

    let speed = pipe_speed_for_score(g.score)
    for(g.pipes) p:
        p.x -= speed * dt

    if g.pipes.length == 0 or g.pipes.top().x < pipe_spawn_x - pipe_spacing:
        spawn_pipe(g)

    g.pipes = filter(g.pipes): _.x > pipe_remove_x
    update_pipe_scores(g)

    if bird_out_of_bounds(g.bird):
        end_game(g)
    else:
        for(g.pipes) p:
            if bird_hits_pipe(g.bird, p):
                end_game(g)
                return
