extends KinematicBody2D

const GRAVITY = 400
const INIT_Y = 1000

const DAMAGE = 60
const KNOCK_BACK_VEL_X = 400
const KNOCK_BACK_FADE_RATE = 900
const KNOCK_BACK_VEL_Y = 300

const LIFETIME = 8

var lifetime_timestamp
var gravity_movement

func _ready():
    gravity_movement = preload("res://Scripts/Movements/GravityMovement.gd").new(self, GRAVITY)
    gravity_movement.dy = INIT_Y
    lifetime_timestamp = OS.get_unix_time()

func _process(delta):
    gravity_movement.move(delta)

    if gravity_movement.is_landed || OS.get_unix_time() - lifetime_timestamp > LIFETIME:
        explode()

func explode():
    $AnimationPlayer.play("Explode")
    set_process(false)

func attack_hit(area):
    if area.is_in_group("hero"):
        explode()

        var character = area.get_node("..")
        character.damaged(DAMAGE)
        character.knocked_back(-KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)