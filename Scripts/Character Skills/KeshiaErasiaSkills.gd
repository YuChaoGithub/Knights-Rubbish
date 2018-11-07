extends Node2D

# Constants for skills.
const BASIC_ATTACK_DURATION = 0.8
const BASIC_ATTACK_COOLDOWN = 0.15
const BASIC_ATTACK_DAMAGE_MIN = 20
const BASIC_ATTACK_DAMAGE_MAX = 35
const BASIC_ATTACK_KNOCK_BACK_VEL_X = 300
const BASIC_ATTACK_KNOCK_BACK_VEL_Y = 50
const BASIC_ATTACK_KNOCK_BACK_FADE_RATE = 600

const BASIC_SKILL_HOP_DURATION = 0.6
const BASIC_SKILL_LAND_DURATION = 0.25
const BASIC_SKILL_COOLDOWN = 0.1
const BASIC_SKILL_DAMAGE_MIN = 10
const BASIC_SKILL_DAMAGE_MAX = 15
const BASIC_SKILL_KNOCK_BACK_VEL_X = 950
const BASIC_SKILL_KNOCK_BACK_VEL_Y = 50
const BASIC_SKILL_KNOCK_BACK_FADE_RATE = 1200
const BASIC_SKILL_STUN_DURATION = 2

const HORIZONTAL_SKILL_DURATION = 0.8
const HORIZONTAL_SKILL_TOSS_TIME = 0.6
const HORIZONTAL_SKILL_COOLDOWN = 0.15

const UP_SKILL_DURATION = 0.7
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_DISPLACEMENT = 150.0
const UP_SKILL_DAMAGE_MIN = 15
const UP_SKILL_DAMAGE_MAX = 30
const UP_SKILL_KNOCK_BACK_VEL_X = 500
const UP_SKILL_KNOCK_BACK_VEL_Y = 300
const UP_SKILL_KNOCK_BACK_FADE_RATE = 500
const UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC = 250

const DOWN_SKILL_DURATION = 1.2
const DOWN_SKILL_RESUME_COOLDOWN = 0.2
const DOWN_SKILL_RESUME_DURATION = 0.4
const DOWN_SKILL_COOLDOWN = 0.15
const DOWN_SKILL_DEFENSE_MODIFIER = 0.3

const ULT_TOTAL_DURATION = 4.5
const ULT_FIRE_TIME = 3.9

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var pencil_dart = preload("res://Scenes/Characters/Keshia Erasia/Pencil Dart.tscn")
var skill_particles = preload("res://Scenes/Particles/KeshiaSkillParticles.tscn")
var up_skill_puff = preload("res://Scenes/Particles/UpSkillPuffParticles.tscn")

onready var hero = $".."
onready var pencil_toss_pos = $"../Sprite/Pencil Toss Pos"
onready var dart_spawn_node = $"../.."

onready var up_skill_particles_spawn_pos = $"../Sprite/Animation/Body/Left Arm/Left Forearm/Weapon Remote Transform/UpSkillParticlesSpawnPos"
onready var up_skill_puff_spawn_pos = $"../Sprite/Animation/UpSkillPuffSpawnPos"

# When this is true, _process() will perform basic skill landing when the player detects the ground.
var detecting_landing = false

# Can only cast Up Skill one time unless Keshia landed on the ground.
var up_skill_available = true
var up_skill_available_timer = null
var up_skill_targets = []
var up_skill_timestamp = 0   # Offset the time to make sure the hero is in air.

# Whether or not Keshia can cast any skill to resume from Down Skill.
var down_skill_can_resume = false
var down_skill_timer = null

# Ult.
var ult_eraser = preload("res://Scenes/Characters/Keshia Erasia/Keshia Ult Eraser.tscn")
var ult_timer = null

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

# Audio.
onready var bs_smash_audio = $"../Audio/BSSmash"
onready var ult_shoot_audio = $"../Audio/UltShoot"

func _ready():
	# Jumping will always reset the availability of up skill.
	hero.connect("did_jump", self, "reset_up_skill_available")

func _process(delta):
	if hero.is_on_floor():
		# For Up Skill.
		if !up_skill_available && OS.get_ticks_msec() - up_skill_timestamp > UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC && up_skill_available_timer == null:
			# Set up skill to available after cooldown.
			up_skill_available_timer = cd_timer.new(UP_SKILL_COOLDOWN, self, "reset_up_skill_available")

		# For basic skill.
		if detecting_landing:
			detecting_landing = false
			basic_skill_strikes()

func reset_up_skill_available():
	up_skill_available = true

	if up_skill_available_timer != null:
		up_skill_available_timer.destroy_timer()
		up_skill_available_timer = null

# ============
# Basic Attack: Wield pencil, attacks the enemies in the front.
# ============
func basic_attack():
	if hero.status.can_move && hero.status.can_cast_skill:
		hero.play_animation("Basic Attack")

		hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
		hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
		hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)

		# Perform attack (interruptable).
		var strike_timer = cd_timer.new(BASIC_ATTACK_DURATION, self, "basic_attack_strikes")
		hero.register_timer("interruptable_skill", strike_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func basic_attack_strikes():
	# Enabel the collider of basic attack.
	hero.unregister_timer("interruptable_skill")

# Will be signalled by pencil weapon's collder (Area2D).
func on_basic_attack_hit(area):
	if area.is_in_group("enemy"):
		# Damage the enemy.
		var enemy_node = area.get_node("../..")
		var damage = rng.randi_range(BASIC_ATTACK_DAMAGE_MIN, BASIC_ATTACK_DAMAGE_MAX)
		enemy_node.knocked_back(sign(enemy_node.global_position.x - global_position.x) * BASIC_ATTACK_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier,-BASIC_ATTACK_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
		enemy_node.damaged(int(damage * hero.attack_modifier))

# ===========
# Basic Skill: Hop, when it hits the ground, stun enemies around.
# ===========
# Sequence: Hop animation (Can move, can't jump) -> Falling -> Landed on the ground / hit mobs or boss ->
#           Landing animation (Can't move, perform attack).
# ===========
func basic_skill():
	if hero.status.can_move && hero.status.can_cast_skill:
		# Hopping animation.
		hero.play_animation("Basic Skill")

		# Set hero status timer.
		hero.status.animate_movement = false
		hero.status.can_cast_skill = false
		hero.status.can_jump = false
		hero.set_status("no_movement", true, BASIC_SKILL_HOP_DURATION)

		# Reverse hero's velocity y if it is negative (going up), ensure falling after hop.
		if hero.velocity.y < 0:
			hero.velocity.y *= -1

		# Perform falling after the timer.
		var hop_timer = cd_timer.new(BASIC_SKILL_HOP_DURATION, self, "basic_skill_falling")
		hero.register_timer("interruptable_skill", hop_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func basic_skill_falling():
	hero.unregister_timer("interruptable_skill")

	# Landing dection code in _process(delta).
	detecting_landing = true

func basic_skill_strikes():
	# Landing animation.
	hero.play_animation("Basic Skill Landing")

	bs_smash_audio.play()

	# Set hero status timer.
	hero.set_status("animate_movement", false, BASIC_SKILL_LAND_DURATION)
	hero.set_status("can_jump", false, BASIC_SKILL_LAND_DURATION)
	hero.set_status("can_move", false, BASIC_SKILL_LAND_DURATION)
	hero.set_status("can_cast_skill", false, BASIC_SKILL_LAND_DURATION + BASIC_SKILL_COOLDOWN)

# Will be signalled by the hit box when an enemy gets into it.
func on_basic_skill_hit(area):
	if area.is_in_group("enemy"):
		var enemy = area.get_node("../..")
		var damage = rng.randi_range(BASIC_SKILL_DAMAGE_MIN, BASIC_SKILL_DAMAGE_MAX)
		enemy.stunned(BASIC_SKILL_STUN_DURATION)
		enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * BASIC_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier,-BASIC_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)		
		enemy.damaged(int(damage * hero.attack_modifier))

# ================
# Horizontal Skill: Short range poke. (toss the pencil).
# ================
func horizontal_skill(side):
	if hero.status.can_move && hero.status.can_cast_skill:
		# Make the hero face left.
		hero.change_sprite_facing(side)

		# Play animation.
		hero.play_animation("Horizontal Skill")

		# Set hero status timer.
		hero.set_status("animate_movement", false, HORIZONTAL_SKILL_DURATION)
		hero.set_status("can_move", false, HORIZONTAL_SKILL_DURATION)
		hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_DURATION + HORIZONTAL_SKILL_COOLDOWN)

		# Perform tossing (interruptable).
		var toss_timer = cd_timer.new(HORIZONTAL_SKILL_TOSS_TIME, self, "horizontal_skill_toss", side)
		hero.register_timer("interruptable_skill", toss_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func horizontal_skill_toss(side):
	# Spawn pencil dart.
	var dart = pencil_dart.instance()

	dart.initialize(side, hero.attack_modifier, hero.size)

	dart_spawn_node.add_child(dart)
	dart.global_position = pencil_toss_pos.global_position

	hero.unregister_timer("interruptable_skill")

# ========
# Up Skill: Poke the pencil up and jump. (Refresh cooldown when landed on ground.)
# ========
func up_skill():
	if up_skill_available && hero.status.can_move && hero.status.can_cast_skill:
		# Play animation.
		hero.play_animation("Up Skill")

		# Show puff particles only if the hero is in air.
		if !hero.is_on_floor():
			var p = up_skill_puff.instance()
			$"../..".add_child(p)
			p.global_position = up_skill_puff_spawn_pos.global_position

		# Put Up Skill on cooldown until Keshia lands on ground (this is set in _process(delta)).
		up_skill_available = false
		up_skill_timestamp = OS.get_ticks_msec()

		# Set hero status timer.
		hero.set_status("can_jump", false, UP_SKILL_DURATION)
		hero.set_status("can_cast_skill", false, UP_SKILL_DURATION)
		hero.set_status("animate_movement", false, UP_SKILL_DURATION)

		# Jump.
		hero.jump_to_height(UP_SKILL_DISPLACEMENT)

		up_skill_targets.clear()

		# Jump up and damage enemies with the pencil when the timer is on.
		var jump_timer = cd_timer.new(UP_SKILL_DURATION, self, "up_skill_ended")
		hero.register_timer("interruptable_skill", jump_timer)
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func up_skill_ended():
	hero.unregister_timer("interruptable_skill")

# Will be signalled by the hit box of up skill.
func on_up_skill_hit(area):
	if area.is_in_group("enemy"):
		# Can't hit the same object twice.
		if !(area in up_skill_targets):
			var p = skill_particles.instance()
			$"../..".add_child(p)
			p.global_position = up_skill_particles_spawn_pos.global_position

			var damage = rng.randi_range(UP_SKILL_DAMAGE_MIN, UP_SKILL_DAMAGE_MAX)
			var enemy = area.get_node("../..")
			enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * UP_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier,-UP_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, UP_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
			enemy.damaged(int(damage * hero.attack_modifier))
			up_skill_targets.push_back(area)
	
# ==========
# Down Skill: Petrify himself, immobile but invicible. Press skill/attack/jump key to resume from petrification.
# ==========
func down_skill():
	if hero.status.can_move && hero.status.can_cast_skill:
		# Play animation.
		hero.play_animation("Down Skill")

		# Set hero status timer.
		hero.status.can_move = false
		hero.status.cc_immune = true
		hero.status.animate_movement = false
		hero.status.can_cast_skill = false
		hero.defense_modifier *= DOWN_SKILL_DEFENSE_MODIFIER

		# Can resume after the timer is up.
		down_skill_timer = cd_timer.new(DOWN_SKILL_DURATION + DOWN_SKILL_RESUME_COOLDOWN, self, "set_down_skill_can_resume")
	elif down_skill_can_resume:
		# Resume from down skill.
		resume_from_down_skill()

func set_down_skill_can_resume():
	down_skill_can_resume = true
	down_skill_timer = null

# Being called in every other skills.
func resume_from_down_skill():
	# Play resume animation.
	hero.play_animation("Down Skill Resume")

	down_skill_can_resume = false

	# Reset hero status when the timer's up.
	down_skill_timer = cd_timer.new(DOWN_SKILL_RESUME_DURATION, self, "reset_status_from_down_skill")

	# Cooldown.
	hero.set_status("can_cast_skill", false, DOWN_SKILL_RESUME_DURATION + DOWN_SKILL_COOLDOWN)

func reset_status_from_down_skill():
	hero.status.can_move = true
	hero.status.cc_immune = false
	hero.status.animate_movement = true
	hero.defense_modifier /= DOWN_SKILL_DEFENSE_MODIFIER
	down_skill_timer = null
	
# ===
# Ult: Full screen high damage attack.
# ===
func ult():
	if hero.status.can_move && hero.status.has_ult && hero.status.can_cast_skill:
		hero.status.has_ult = false

		hero.set_status("can_move", false, ULT_TOTAL_DURATION)
		hero.set_status("can_jump", false, ULT_TOTAL_DURATION)
		hero.set_status("can_cast_skill", false, ULT_TOTAL_DURATION)
		hero.set_status("animate_movement", false, ULT_TOTAL_DURATION)
		hero.set_status("invincible", true, ULT_TOTAL_DURATION)
		hero.set_status("no_movement", true, ULT_TOTAL_DURATION)

		hero.get_node("Keshia Ult/AnimationPlayer").play("Forming Circle")
		hero.play_animation("Ult")

		ult_timer = cd_timer.new(ULT_FIRE_TIME, self, "fire_ult")

func fire_ult():
	ult_shoot_audio.play()
	hero.release_ult()
	hero.get_node("Ult Hit Box").global_position = hero.following_camera.global_position

func ult_hit(area):
	if area.is_in_group("enemy"):
		var new_eraser = ult_eraser.instance()
		new_eraser.initialize(hero.global_position, area.get_node("../.."))
		hero.get_node("..").add_child(new_eraser)
		new_eraser.global_position = hero.global_position

func cancel_all_skills():
	# Basic Skill Falling.
	if detecting_landing:
		detecting_landing = false
		hero.status.animate_movement = true
		hero.status.can_cast_skill = true
		hero.status.can_jump = true

	# Down Skill.
	if down_skill_timer != null:
		down_skill_timer.time_out()
	
	if down_skill_can_resume:
		down_skill_can_resume = false
		reset_status_from_down_skill()