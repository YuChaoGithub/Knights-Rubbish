extends Node2D

const HERO_FADE_DURATION = 0.15
const HERO_FREEZE_DURATION = 0.3

export(NodePath) var destination_node_path

var is_active = false
var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")

onready var init_color = modulate
onready var blink_animator = $WhiteCover/AnimationPlayer
onready var destination = get_node(destination_node_path)
onready var particles = $Particles2D
onready var frame = $Frame
onready var cover_frame = $CoverFrame
onready var ban_sign = $BanSign
onready var following_camera = $"../../FollowingCamera"

func _ready():
    deactivate()

func _process(delta):
    if is_active && !following_camera.in_camera_view(destination.global_position):
        deactivate()
    elif !is_active && following_camera.in_camera_view(destination.global_position):
        activate()

func hero_enter(hero):
    if is_active:
        hero.set_status("can_move", false, HERO_FREEZE_DURATION)
        
        var lerper = parent_lerper.instance()
        lerper.initialize(hero.modulate.a, 0.0, HERO_FADE_DURATION, hero, "reset_alpha_and_teleport_to_position", destination.global_position)
        hero.add_child(lerper)

        blink_animator.play("Blink")

func deactivate():
    is_active = false

    modulate = Color(1.0, 1.0, 1.0)

    frame.visible = false
    cover_frame.visible = false
    particles.visible = false
    ban_sign.visible = true

func activate():
    is_active = true

    modulate = init_color

    frame.visible = true
    cover_frame.visible = true
    particles.visible = true
    ban_sign.visible = false