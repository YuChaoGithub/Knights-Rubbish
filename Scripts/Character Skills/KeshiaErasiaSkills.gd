extends Node2D

# Constants for skills.
const BASIC_ATTACK_DURATION = 0.3
const BASIC_ATTACK_STRIKES_TIME = 0.1
const BASIC_ATTACK_COOLDOWN = 0.15
const BASIC_ATTACK_DAMAGE = 29

const BASIC_SKILL_HOP_DURATION = 0.6
const BASIC_SKILL_LAND_DURATION = 0.25
const BASIC_SKILL_HIT_BOX_DURATION = 0.1
const BASIC_SKILL_COOLDOWN = 0.1
const BASIC_SKILL_STUN_DURATION = 2

const HORIZONTAL_SKILL_DURATION = 0.8
const HORIZONTAL_SKILL_TOSS_TIME = 0.6
const HORIZONTAL_SKILL_COOLDOWN = 0.15

const UP_SKILL_DURATION = 0.7
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_LANDED_DETECTION_DELAY = 0.05
const UP_SKILL_VELOCITY = -850
const UP_SKILL_DAMAGE = 5

const DOWN_SKILL_DURATION = 0.6
const DOWN_SKILL_RESUME_COOLDOWN = 0.2
const DOWN_SKILL_RESUME_DURATION = 0.4
const DOWN_SKILL_COOLDOWN = 0.15

# To get the can_move/can_cast_skill variables.
onready var character = get_node("..")

# For horizontal skill.
var countdown_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var pencil_dart = preload("res://Scenes/Characters/Keshia Erasia/Pencil Dart.tscn")
onready var pencil_toss_pos = get_node("../Pencil Toss Pos").get_pos()
onready var dart_spawn_node = character.get_node("..")

# When this is true, _process() will perform basic skill landing when the player detects the ground.
var detecting_landing = false

var basic_attack_hit = true

# Can only cast Up Skill one time unless Keshia landed on the ground.
var up_skill_available = true
var up_skill_available_timer = null
var up_skill_targets = []

# The time when up skill is casted.
# Is used to produce some latency between landed on ground detection.
var up_skill_cast_timestamp = 0

# Whether or not Keshia can cast any skill to resume from Down Skill.
var down_skill_can_resume = false
var down_skill_timer = null

var hit_box_timer = null

# Hit boxes of attack/skills.
onready var basic_attack_hit_box = get_node("../Sprite/Animation/Body/Left Arm/Weapon/Basic Attack Hit Box")
onready var basic_skill_hit_box = get_node("../Sprite/Basic Skill Hit Box")
onready var up_skill_hit_box = get_node("../Sprite/Animation/Body/Left Arm/Weapon/Up Skill Hit Box")

func _ready():
	set_process(true)

	# Jumping will always reset the availability of up skill.
	character.jump_event.push_back([self, "reset_up_skill_available"])

func _process(delta):
	if character.landed_on_ground:
		# For Up Skill.
		if not up_skill_available and up_skill_available_timer == null and OS.get_unix_time() - up_skill_cast_timestamp > UP_SKILL_LANDED_DETECTION_DELAY:
			# Set up skill to available after cooldown.
			up_skill_available_timer = countdown_timer.new(UP_SKILL_COOLDOWN, self, "reset_up_skill_available")
			
			# Reset timestamp.
			up_skill_cast_timestamp = 0

		# For basic skill.
		if detecting_landing:
			detecting_landing = false
			basic_skill_strikes()

func reset_up_skill_available():
	up_skill_available = true
	up_skill_available_timer = null

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
		var strike_timer = countdown_timer.new(BASIC_ATTACK_STRIKES_TIME, self, "basic_attack_strikes")
		character.register_timer("interruptable_skill", strike_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func basic_attack_strikes():
	# Enabel the collider of basic attack.
	character.unregister_timer("interruptable_skill")
	basic_attack_hit = false

# Will be signalled by pencil weapon's collder (Area2D).
func on_basic_attack_hit(area):
	if !basic_attack_hit && area.is_in_group("enemy_collider"):
		# Damage the enemy.
		var enemy_node = area.get_node("../..")
		enemy_node.damaged(BASIC_ATTACK_DAMAGE)
		basic_attack_hit = true

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
		character.status.can_cast_skill = false
		character.status.can_jump = false
		character.set_status("no_movement", true, BASIC_SKILL_HOP_DURATION)

		# Reverse character's velocity y if it is negative (going up), ensure falling after hop.
		if character.velocity.y < 0:
			character.velocity.y *= -1

		# Perform falling after the timer.
		var hop_timer = countdown_timer.new(BASIC_SKILL_HOP_DURATION, self, "basic_skill_falling")
		character.register_timer("interruptable_skill", hop_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func basic_skill_falling():
	character.status.invincible = true

	character.unregister_timer("interruptable_skill")

	# Landing dection code in _process(delta).
	detecting_landing = true

func basic_skill_strikes():
	# Landing animation.
	character.play_animation("Basic Skill Landing")

	# Set character status timer.
	character.set_status("animate_movement", false, BASIC_SKILL_LAND_DURATION)
	character.set_status("can_jump", false, BASIC_SKILL_LAND_DURATION)
	character.set_status("can_move", false, BASIC_SKILL_LAND_DURATION)
	character.set_status("can_cast_skill", false, BASIC_SKILL_LAND_DURATION + BASIC_SKILL_COOLDOWN)
	character.set_status("invincible", true, BASIC_SKILL_LAND_DURATION)

# Will be signalled by the hit box when an enemy gets into it.
func on_basic_skill_hit(area):
	if area.is_in_group("enemy_collider"):
		# Stun the enemy.
		area.get_node("../..").stunned(BASIC_SKILL_STUN_DURATION)

# ================
# Horizontal Skill: Short range poke. (toss the pencil).
# ================
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
		var toss_timer = countdown_timer.new(HORIZONTAL_SKILL_TOSS_TIME, self, "horizontal_skill_toss", side)
		character.register_timer("interruptable_skill", toss_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func horizontal_skill_toss(side):
	# Spawn pencil dart.
	var dart = pencil_dart.instance()

	# Set position and facing.
	dart.side = side

	dart_spawn_node.add_child(dart)
	dart.set_pos(character.get_pos() + pencil_toss_pos)

	character.unregister_timer("interruptable_skill")

# ========
# Up Skill: Poke the pencil up and jump. (Refresh cooldown when landed on ground.)
# ========
func up_skill():
	if up_skill_available and character.status.can_move and character.status.can_cast_skill:
		# Play animation.
		character.play_animation("Up Skill")

		# Put Up Skill on cooldown until Keshia lands on ground (this is set in _process(delta)).
		up_skill_available = false

		# Set character status timer.
		character.set_status("can_jump", false, UP_SKILL_DURATION)
		character.set_status("can_cast_skill", false, UP_SKILL_DURATION)
		character.set_status("animate_movement", false, UP_SKILL_DURATION)

		# Jump.
		character.velocity_replacement_y = UP_SKILL_VELOCITY

		# Record a timestamp, so that there will be a short delay between before landed on ground detection.
		up_skill_cast_timestamp = OS.get_unix_time()

		up_skill_targets.clear()

		# Jump up and damage enemies with the pencil when the timer is on.
		var jump_timer = countdown_timer.new(UP_SKILL_DURATION, self, "up_skill_ended")
		character.register_timer("movement_skill", jump_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func up_skill_ended():
	character.unregister_timer("movement_skill")

# Will be signalled by the hit box of up skill.
func on_up_skill_hit(area):
	if area.is_in_group("enemy_collider"):
		# Can't hit the same object twice.
		if !(area in up_skill_targets):
			area.get_node("../..").damaged(UP_SKILL_DAMAGE)
			up_skill_targets.push_back(area)
	
# ==========
# Down Skill: Petrify himself, immobile but invicible. Press skill/attack/jump key to resume from petrification.
# ==========
func down_skill():
	if character.status.can_cast_skill and character.status.can_cast_skill:
		# Play animation.
		character.play_animation("Down Skill")

		# Set character status timer.
		character.status.can_move = false
		character.status.invincible = true
		character.status.animate_movement = false
		character.status.can_cast_skill = false

		# Can resume after the timer is up.
		down_skill_timer = countdown_timer.new(DOWN_SKILL_DURATION + DOWN_SKILL_RESUME_COOLDOWN, self, "set_down_skill_can_resume")
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func set_down_skill_can_resume():
	down_skill_can_resume = true
	down_skill_timer = null

# Being called in every other skills.
func resume_from_down_skill():
	# Play resume animation.
	character.play_animation("Down Skill Resume")

	down_skill_can_resume = false

	# Reset character status when the timer's up.
	down_skill_timer = countdown_timer.new(DOWN_SKILL_RESUME_DURATION, self, "reset_status_from_down_skill")

	# Cooldown.
	character.set_status("can_cast_skill", false, DOWN_SKILL_RESUME_DURATION + DOWN_SKILL_COOLDOWN)

func reset_status_from_down_skill():
	character.status.can_move = true
	character.status.invincible = false
	character.status.animate_movement = true
	down_skill_timer = null
	
func ult():
	pass