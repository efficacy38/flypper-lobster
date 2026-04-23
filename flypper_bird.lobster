import std
import vec
import color
import gl

fatal(gl.window("Flypper Bird (Lobster)", 960, 640))

let world_w = 22.0
let world_h = 16.0
let half_w = world_w / 2.0
let half_h = world_h / 2.0

let bird_x = -6.0
let bird_radius = 0.45

let gravity = -25.0
let flap_velocity = 9.0
let scroll_speed = 5.0

let pipe_width = 2.2
let pipe_gap = 3.6
let pipe_spacing = 6.5
let pipe_count = 4

let ground_y = -half_h + 1.2

class pipe:
    x:float
    gap_y:float
    passed:int

def random_gap():
    let min_gap = ground_y + pipe_gap / 2.0 + 0.9
    let max_gap = half_h - pipe_gap / 2.0 - 0.9
    min_gap + div(rnd(10000), 10000) * (max_gap - min_gap)

def make_initial_pipes():
    var created = []
    for(pipe_count) i:
        created.push(pipe {
            half_w + 4.0 + i * pipe_spacing,
            random_gap(),
            false
        })
    created

var bird_y = 0.0
var bird_vy = 0.0
var bird_tilt = 0.0
var alive = true
var score = 0
var best_score = 0
var pipes = make_initial_pipes()

while gl.frame() and gl.button("escape") != 1:
    let dt = gl.delta_time()

    let flap_pressed = gl.button("space") == 1 or gl.button("mouse1") == 1

    if alive and flap_pressed:
        bird_vy = flap_velocity

    if not alive and flap_pressed:
        bird_y = 0.0
        bird_vy = 0.0
        bird_tilt = 0.0
        score = 0
        alive = true
        pipes = make_initial_pipes()

    if alive:
        bird_vy += gravity * dt
        bird_y += bird_vy * dt
        bird_tilt = clamp(bird_vy / 12.0, -1.0, 1.0)

        var rightmost = -1000.0
        for(pipes) p:
            p.x -= scroll_speed * dt
            rightmost = max(rightmost, p.x)

            if not p.passed and p.x + pipe_width / 2.0 < bird_x:
                p.passed = true
                score += 1
                best_score = max(best_score, score)

        for(pipes) p:
            if p.x + pipe_width / 2.0 < -half_w - 0.5:
                p.x = rightmost + pipe_spacing
                p.gap_y = random_gap()
                p.passed = false
                rightmost = p.x

        if bird_y - bird_radius < ground_y or bird_y + bird_radius > half_h:
            alive = false

        for(pipes) p:
            let overlap_x = abs(bird_x - p.x) < (pipe_width / 2.0 + bird_radius)
            if overlap_x:
                let bottom_pipe_top = p.gap_y - pipe_gap / 2.0
                let top_pipe_bottom = p.gap_y + pipe_gap / 2.0
                if bird_y - bird_radius < bottom_pipe_top or bird_y + bird_radius > top_pipe_bottom:
                    alive = false

    gl.clear(float4 { 0.54, 0.82, 0.95, 1.0 })

    gl.translate(float(gl.window_size()) / 2.0)
    let scale = gl.window_size().y / world_h
    gl.scale(scale)

    gl.color(float4 { 0.95, 0.95, 0.98, 1.0 })
    for(12) i:
        let cloud = float2 { -half_w + i * 2.3 + gl.time() * 0.25 - floor((gl.time() * 0.25 + i * 2.3) / (world_w + 4.6)) * (world_w + 4.6), half_h - 1.8 - mod(i, 3) * 0.45 }
        gl.translate cloud:
            gl.circle(0.25 + mod(i, 3) * 0.08, 20)

    gl.color(float4 { 0.47, 0.77, 0.26, 1.0 })
    gl.translate(float2 { -half_w, -half_h }):
        gl.rect(float2 { world_w, ground_y + half_h })

    for(pipes) p:
        let bottom_h = p.gap_y - pipe_gap / 2.0 + half_h
        let top_h = half_h - (p.gap_y + pipe_gap / 2.0)

        gl.color(float4 { 0.20, 0.70, 0.23, 1.0 })
        gl.translate(float2 { p.x - pipe_width / 2.0, -half_h }):
            gl.rect(float2 { pipe_width, bottom_h })
        gl.translate(float2 { p.x - pipe_width / 2.0, p.gap_y + pipe_gap / 2.0 }):
            gl.rect(float2 { pipe_width, top_h })

    gl.translate(float2 { bird_x, bird_y }):
        gl.rotate_z(float2 { 1.0, bird_tilt * 0.35 }):
            gl.color(if alive: color_yellow else: float4 { 0.8, 0.5, 0.5, 1.0 })
            gl.circle(bird_radius, 28)
            gl.color(float4 { 1.0, 0.6, 0.1, 1.0 })
            gl.translate(float2 { 0.35, 0.0 }):
                gl.polygon([
                    float2 { 0.0, 0.12 },
                    float2 { 0.45, 0.0 },
                    float2 { 0.0, -0.12 }
                ])
            gl.color(color_white)
            gl.translate(float2 { -0.12, 0.14 }):
                gl.circle(0.09, 16)

    # Tiny score pips (top-left) to avoid font dependencies.
    for(score) i:
        gl.color(float4 { 1.0, 0.95, 0.35, 1.0 })
        gl.translate(float2 { -half_w + 0.45 + i * 0.30, half_h - 0.55 }):
            gl.circle(0.09, 14)

    if not alive:
        gl.color(float4 { 0.95, 0.25, 0.30, 1.0 })
        gl.translate(float2 { 0.0, 0.0 }):
            gl.open_circle(0.95, 36, 0.16)

        # Show best score as white pips below the center.
        for(best_score) i:
            gl.color(color_white)
            gl.translate(float2 { -0.15 * best_score + i * 0.30, -1.5 }):
                gl.circle(0.08, 14)
