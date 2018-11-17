extends Node2D

# Clockwork Fox AI:
# 1. When player goes near activate.
# 2. Shoot fire for certain intervals.

signal defeated

enum { NONE, ACTIVATE_ANIM, STILL, FIRE }

export(int) var activate_range_x = 800
export(int) var activate_range_y = 1000
export(float) var still_interval = 2.5

const MAX_HEALTH = 450

# Attack.
const DAMAGE = 10
const KNOCK_BACK_VEL_X = 100
const KNOCK_BACK_VEL_Y = 50
const KNOCK_BACK_FADE_RATE = 150

# Animation.
const FIRE_ANIMATION_DURATION = 5.0
const ACTIVATE_ANIMATION_DURATION = 0.5
const DIE_ANIMATION_DURATION = 0.8

var status_timer = null
var die_timer = null
var activate_timer = null

onready var ec = preload("res://Scripts/Enemies/Common/EnemyCommon.gd").new(self)

func activate():
	set_process(true)
	ec.change_status(ACTIVATE_ANIM)
	$"Animation/Damage Area".add_to_group("enemy")

func _process(delta):
	if ec.not_hurt_dying_stunned():
		match ec.status:
			ACTIVATE_ANIM:
				play_activate_anim()
			STILL:
				still()
			FIRE:
				fire()

func change_status(to_status):
	ec.change_status(to_status)

func play_activate_anim():
	ec.play_animation("Activate")
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(ACTIVATE_ANIMATION_DURATION, self, "change_status", STILL)

func still():
	ec.play_animation("Activated Still")

	if activate_timer == null:
		activate_timer = ec.cd_timer.new(still_interval, self, "change_status", FIRE)

func fire():
	ec.play_animation("Fire")
	activate_timer = null
	ec.change_status(NONE)
	status_timer = ec.cd_timer.new(FIRE_ANIMATION_DURATION, self, "change_status", STILL)

func on_attack_hit(area):
	if area.is_in_group("hero"):
		var character = area.get_node("..")
		character.damaged(DAMAGE)
		character.knocked_back(-sign(scale.x) * KNOCK_BACK_VEL_X, -KNOCK_BACK_VEL_Y, KNOCK_BACK_FADE_RATE)

func cancel_activate_timer():
	if activate_timer != null:
		activate_timer.destroy_timer()
		activate_timer = null

func damaged(val):
	ec.damaged(val, ec.animator.current_animation == "Activated Still")

func resume_from_damaged():
	ec.resume_from_damaged()

func stunned(duration):
	cancel_activate_timer()
	ec.change_status(STILL)
	ec.stunned(duration)

func resume_from_stunned():
	ec.resume_from_stunned()

func healed(val):
	ec.healed(val)

func knocked_back(vel_x, vel_y, fade_rate):
	return

func slowed(multiplier, duration):
	return

func die():
	ec.die()
	emit_signal("defeated")
	die_timer = ec.cd_timer.new(DIE_ANIMATION_DURATION, self, "queue_free")