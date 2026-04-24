import std
import vec
import color
import gl
import from "./"
import game_model

pakfile "../assets/"

fatal(gl.window("Flypper Lobster", int(screen_width), int(screen_height)))
check(gl.set_font_name(pakfile "../assets/fonts/US101.ttf") and gl.set_font_size(28), "font setup failed")

let background_tex = gl.load_texture(pakfile "../assets/background.png")
let ground_tex = gl.load_texture(pakfile "../assets/ground.png")
let bird_tex = gl.load_texture(pakfile "../assets/bird.png")
let pipe_tex = gl.load_texture(pakfile "../assets/pipe.png")
assert background_tex
assert ground_tex
assert bird_tex
assert pipe_tex

let music_channel = play_ogg(pakfile "../assets/audio/music.ogg", -1)
if music_channel:
    sound_volume(music_channel, 0.28)

let game = new_game()
let non_interactive_test = exists(command_line_arguments()): _ == "--non-interactive-test"
var previous_score = 0
var ground_scroll = 0.0
var frames = 0

def draw_texture(tex, pos:float2, size:float2):
    gl.set_shader("textured")
    gl.set_primitive_texture(0, tex)
    gl.color(color_white)
    gl.translate pos:
        gl.scale(size / 2.0):
            gl.rect(float2_1, 1)
    gl.set_shader("color")

def draw_background():
    draw_texture(background_tex, float2 { screen_width / 2.0, screen_height / 2.0 }, float2 { screen_width, screen_height })

def draw_ground(dt:float):
    ground_scroll = (ground_scroll + pipe_speed_for_score(game.score) * dt) % screen_width
    draw_texture(ground_tex, float2 { screen_width / 2.0 - ground_scroll, ground_y / 2.0 }, float2 { screen_width, ground_y })
    draw_texture(ground_tex, float2 { screen_width * 1.5 - ground_scroll, ground_y / 2.0 }, float2 { screen_width, ground_y })

def draw_pipe(p::pipe):
    let top_height = screen_height - (p.gap_y + pipe_gap / 2.0)
    let bottom_height = p.gap_y - pipe_gap / 2.0 - ground_y
    draw_texture(pipe_tex, float2 { p.x, ground_y + bottom_height / 2.0 }, float2 { pipe_width, bottom_height })
    gl.translate float2 { p.x, p.gap_y + pipe_gap / 2.0 + top_height / 2.0 }:
        gl.scale(float2 { pipe_width / 2.0, -top_height / 2.0 }):
            gl.set_shader("textured")
            gl.set_primitive_texture(0, pipe_tex)
            gl.color(color_white)
            gl.rect(float2_1, 1)
            gl.set_shader("color")

def draw_bird():
    gl.translate float2 { bird_x, game.bird.y }:
        gl.rotate_z(sincos(game.bird.tilt * 40.0))
        draw_texture(bird_tex, float2_0, float2 { 58.0, 42.0 })

def draw_center_text(title:string, subtitle:string):
    let title_size = gl.text_size(title)
    gl.color(color_white)
    gl.translate float2 { (screen_width - title_size.x) / 2.0, screen_height * 0.62 }:
        gl.text(title)
    let subtitle_size = gl.text_size(subtitle)
    gl.translate float2 { (screen_width - subtitle_size.x) / 2.0, screen_height * 0.55 }:
        gl.text(subtitle)

def draw_hud():
    let score_text = "{game.score}"
    let score_size = gl.text_size(score_text)
    gl.color(color_white)
    gl.translate float2 { (screen_width - score_size.x) / 2.0, screen_height - 74.0 }:
        gl.text(score_text)
    let high_text = "BEST {game.high_score}"
    gl.translate float2 { 18.0, screen_height - 44.0 }:
        gl.text(high_text)

def handle_action():
    let space_down = gl.button("space")
    let mouse_down = gl.button("mouse1")
    if space_down == 1 or mouse_down == 1:
        if game.mode == mode_game_over:
            reset(game)
            previous_score = 0
        flap(game)
        play_wav(pakfile "../assets/audio/flap.wav")

while gl.frame() and gl.button("escape") != 1 and not (non_interactive_test and frames > 0):
    let dt = min(gl.delta_time(), 0.033)
    handle_action()
    update(game, dt)
    if game.score > previous_score:
        previous_score = game.score
        play_wav(pakfile "../assets/audio/score.wav")
    if game.mode == mode_game_over and previous_score != -1:
        previous_score = -1
        play_wav(pakfile "../assets/audio/hit.wav")
    if game.mode != mode_game_over and previous_score == -1:
        previous_score = game.score

    gl.clear(float4 { 0.37, 0.72, 0.89, 1.0 })
    draw_background()
    for(game.pipes) p:
        draw_pipe(p)
    draw_ground(dt)
    draw_bird()
    draw_hud()

    if game.mode == mode_waiting:
        draw_center_text("FLYPPER LOBSTER", "SPACE / CLICK")
    elif game.mode == mode_game_over:
        draw_center_text("GAME OVER", "SPACE / CLICK")

    frames++
