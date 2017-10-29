extends KinematicBody2D

# CD Punch AI:
# 1. Detect the nearest character as its target.
# 2. Move until it is in range of the target.
# 3. Punch.
# 4. Repeat 1.

const MAX_HEALTH = 100
const ACTIVATE_RANGE = 1000
const ATTACK_RANGE = 30
const SPEED_X = 350
const SPEED_Y = 600   # (aka. gravity)

var curr_health
var activated = false

# The movement type of CD Punch. Will be initialized in _ready().
var movement_type

var activate_detection

var nearest_target_detect = preload("res://Scripts/Algorithms/NearestTargetDetection.gd")
onready var char_average_pos = get_node("../../../../Character Average Position")

func _ready():
    movement_type = preload("res://Scripts/Movements/StraightLineMovement.gd").new(SPEED_X, SPEED_Y)
    activate_detection = preload("res://Scripts/Enemies/Common/ActivateDetection.gd").new(self, char_average_pos, ACTIVATE_RANGE)

func _process(delta):
    pass

func activate():
    curr_health = MAX_HEALTH