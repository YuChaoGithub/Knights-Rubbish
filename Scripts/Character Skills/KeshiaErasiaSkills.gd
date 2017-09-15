extends Node2D

const TIMER_PATH = "res://Scripts/Utils/CountdownTimer.gd"

# Constants for skills.
const BASIC_ATTACK_DURATION = 0.3
const BASIC_ATTACK_STRIKES_TIME = 0.15
const BASIC_ATTACK_COOLDOWN = 0.15

const BASIC_SKILL_HOP_DURATION = 0.6
const BASIC_SKILL_LAND_DURATION = 0.25
const BASIC_SKILL_COOLDOWN = 0.1

const HORIZONTAL_SKILL_DURATION = 0.8
const HORIZONTAL_SKILL_TOSS_TIME = 0.6
const HORIZONTAL_SKILL_COOLDOWN = 0.15

# For horizontal skill.
var pencil_dart = preload("res://Scenes/Characters/Keshia Erasia/Pencil Dart.tscn")
onready var pencil_toss_pos = get_node("../Pencil Toss Pos").get_pos()
onready var dart_spawn_node = get_tree().get_root().get_node("Game Level")

# When this is true, _process() will perform basic skill landing when the player detects the ground.
var detecting_landing = false

# To get the can_move/can_cast_skill variables.
onready var character = get_node("..")

func _ready():
	set_process(true)

func _process(delta):
	# For basic skill.
	if detecting_landing and character.landed_on_ground:
		detecting_landing = false
		basic_skill_strikes()

# ============
# Basic Attack: Wield pencil, attacks the enemies in the front.
# ============
func basic_attack():
	if character.status.can_move and character.status.can_cast_skill:
		# Play animation.
		character.play_animation("Basic Attack")

		# Set character status timers.
		character.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
		character.set_status("can_move", false, BASIC_ATTACK_DURATION)
		character.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)

		# Perform attack (interruptable).
		var strike_timer = preload(TIMER_PATH).new(BASIC_ATTACK_STRIKES_TIME, self, "basic_attack_strikes")
		character.register_timer("interruptable_skill", strike_timer)

func basic_attack_strikes():
	# TODO: Do damage.
	character.unregister_timer("interruptable_skill")

# ===========
# Basic Skill: Hop, when it hits the ground, stun enemies around. Is invincible while hitting ground.
# ===========
# Sequence: Hop animation (Can move, can't jump) -> Falling (Invincible) -> Landed on the ground / hit mobs or boss ->
#           Landing animation (Can't move, Invincible, perform attack).
# ===========
func basic_skill():
	if character.status.can_move and character.status.can_cast_skill:
		# Hopping animation.
		character.play_animation("Basic Skill")

		# Set character status timer.
		character.status.animate_movement = false
		character.set_status("can_cast_skill", false, BASIC_SKILL_HOP_DURATION)
		character.set_status("can_jump", false, BASIC_SKILL_HOP_DURATION)
		character.set_status("no_movement", true, BASIC_SKILL_HOP_DURATION)

		# Reverse character's velocity y if it is negative (going up), ensure falling after hop.
		if character.velocity.y < 0:
			character.velocity.y *= -1

		# Perform falling after the timer.
		var hop_timer = preload(TIMER_PATH).new(BASIC_SKILL_HOP_DURATION, self, "basic_skill_falling")
		character.register_timer("interruptable_skill", hop_timer)

func basic_skill_falling():
	character.status.invincible = true
	character.status.animated_movement = false

	character.unregister_timer("interruptable_skill")

	# Landing dection code in _process(delta).
	detecting_landing = true

func basic_skill_strikes():
	# Landing animation.
	character.play_animation("Basic Skill Landing")

	# Set character status timer.
	character.set_status("animate_movement", false, BASIC_SKILL_LAND_DURATION)
	character.set_status("can_move", false, BASIC_SKILL_LAND_DURATION)
	character.set_status("can_cast_skill", false, BASIC_SKILL_LAND_DURATION + BASIC_SKILL_COOLDOWN)
	character.set_status("invincible", true, BASIC_SKILL_LAND_DURATION)

	# TODO: Do damage, stun surrounding mobs.

# ==========
# Horizontal Skill: Short range poke. (toss the pencil).
# ==========
func horizontal_skill(side):
	if character.status.can_move and character.status.can_cast_skill:
		# Make the character face left.
		character.change_sprite_facing(side)

		# Play animation.
		character.play_animation("Horizontal Skill")

		# Set character status timer.
		character.set_status("animate_movement", false, HORIZONTAL_SKILL_DURATION)
		character.set_status("can_move", false, HORIZONTAL_SKILL_DURATION)
		character.set_status("can_cast_skill", false, HORIZONTAL_SKILL_DURATION + HORIZONTAL_SKILL_COOLDOWN)

		# Perform tossing (interruptable).
		var toss_timer = preload(TIMER_PATH).new(HORIZONTAL_SKILL_TOSS_TIME, self, "horizontal_skill_toss", side)
		character.register_timer("interruptable_skill", toss_timer)

func horizontal_skill_toss(side):
	# Spawn pencil dart.
	var dart = pencil_dart.instance()

	# Set position and facing.
	dart.set_pos(character.get_global_pos() + pencil_toss_pos)
	dart.side = side

	dart_spawn_node.add_child(dart)

	character.unregister_timer("interruptable_skill")
	
func up_skill():
	pass
	
func down_skill():
	pass
	
func ult():
	pass