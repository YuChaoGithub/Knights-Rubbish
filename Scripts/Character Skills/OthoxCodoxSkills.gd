extends Node2D

# Basic Attack.
const BASIC_ATTACK_DURATION = 3.0
const BASIC_ATTACK_COOLDOWN = 0.1
const BASIC_ATTACK_DAMAGE_MIN = 130
const BASIC_ATTACK_DAMAGE_MAX = 150
const BASIC_ATTACK_KNOCK_BACK_VEL_X = 500
const BASIC_ATTACK_KNOCK_BACK_VEL_Y = 50
const BASIC_ATTACK_KNOCK_BACK_FADE_RATE = 1000
const BASIC_ATTACK_STUN_DURATION = 1.5

var basic_attack_targets = []

# Basic Skill.
const BASIC_SKILL_DURATION = 3.0
const BASIC_SKILL_COOLDOWN = 0.15
const BASIC_SKILL_RAIN_TIME = 1.5
const BASIC_SKILL_RAIN_COUNT = 60
const BASIC_SKILL_RANGE = 400

var basic_skill_rain = preload("res://Scenes/Characters/Othox Codox/OthoxBasicSkillRain.tscn")
onready var following_camera = $"../../FollowingCamera"
var basic_skill_interval

# Horizontal Skill.
const HORIZONTAL_SKILL_ENDING_DURATION = 0.5
const HORIZONTAL_SKILL_COOLDOWN = 0.15
const HORIZONTAL_SKILL_SHOOT_TIME = 1.0
const HORIZONTAL_SKILL_SHOOT_INTERVAL = 0.5
const HORIZONTAL_SKILL_SHOOT_COUNT = 5

var horizontal_skill_count = 0
var horizontal_skill_letter = preload("res://Scenes/Characters/Othox Codox/OthoxHorizontalSkill.tscn")
onready var horizontal_skill_spawn_pos = $"../Sprite/Animation/HorizontalSkillShootPos"

# Down Skill.
const DOWN_SKILL_DURATION = 3.0
const DOWN_SKILL_COOLDOWN = 0.1
const DOWN_SKILL_HEAL_TIME = 1.7
const DOWN_SKILL_HEAL_AMOUNT = 30

const UP_SKILL_DURATION = 0.85
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_DISPLACEMENT = 75
const UP_SKILL_SECOND_JUMP_TIME = 0.4286
const UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC = 250

var up_skill_available = true
var up_skill_available_timer = null
var up_skill_timestamp = 0

var up_skill_puff = preload("res://Scenes/Particles/UpSkillPuffParticles.tscn")
onready var up_skill_puff_spawn_pos = $"../Sprite/Animation/UpSkillPuffSpawnPos"

# Ult.
const ULT_DURATION = 5.0
const ULT_START_RAIN_TIME = 2.0
const ULT_RAIN_COUNT = 100

var ult_interval
var ult_timer
var ult_rain = preload("res://Scenes/Characters/Othox Codox/OthoxUltRain.tscn")

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
onready var hero = $".."
onready var spawn_node = $"../.."

onready var audios_to_stop_when_stunned = [
    $"../Audio/Drink",
    $"../Audio/BABling",
    $"../Audio/BAHoop",
    $"../Audio/BSRain",
    $"../Audio/DS",
    $"../Audio/HSFlame",
    $"../Audio/HSShoot",
    $"../Audio/US"
]

func _ready():
    basic_skill_interval = (BASIC_SKILL_DURATION - BASIC_SKILL_RAIN_TIME) / BASIC_SKILL_RAIN_COUNT
    ult_interval = (ULT_DURATION - ULT_START_RAIN_TIME) / ULT_RAIN_COUNT
    hero.connect("did_jump", self, "reset_up_skill_available")

func _process(delta):
    if hero.is_on_floor():
        if !up_skill_available && OS.get_ticks_msec() - up_skill_timestamp > UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC && up_skill_available == null:
            up_skill_available_timer = cd_timer.new(UP_SKILL_COOLDOWN, self, "reset_up_skill_available")

func reset_up_skill_available():
    up_skill_available = true

    if up_skill_available_timer != null:
        up_skill_available_timer.destroy_timer()
        up_skill_available_timer = null

# Basic Attack: Wields a word-sword.
func basic_attack():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Attack")

        hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)
        
        basic_attack_targets.clear()

        var strike_timer = cd_timer.new(BASIC_ATTACK_DURATION, self, "basic_attack_strikes")
        hero.register_timer("interruptable_skill", strike_timer)

func basic_attack_strikes():
    hero.unregister_timer("interruptable_skill")

func basic_attack_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        if !(enemy in basic_attack_targets):
            basic_attack_targets.push_back(enemy)
            var damage = rng.randi_range(BASIC_ATTACK_DAMAGE_MIN, BASIC_ATTACK_DAMAGE_MAX)
            enemy.stunned(BASIC_ATTACK_STUN_DURATION)
            enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * BASIC_ATTACK_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier,-BASIC_ATTACK_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
            enemy.damaged(int(damage * hero.attack_modifier))

func basic_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Skill")

        hero.set_status("can_move", false, BASIC_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_SKILL_DURATION + BASIC_SKILL_COOLDOWN)
        hero.set_status("animate_movement", false, BASIC_SKILL_DURATION)

        var rain_timer = cd_timer.new(BASIC_SKILL_RAIN_TIME, self, "basic_skill_rains", 0)
        hero.register_timer("interruptable_skill", rain_timer)

func basic_skill_rains(count):
    hero.unregister_timer("interruptable_skill")

    var rain = basic_skill_rain.instance()
    rain.initialize(hero.attack_modifier, hero.size)
    spawn_node.add_child(rain)
    var pos_x = self.global_position.x + hero.size * (rng.randf_range(0.0, BASIC_SKILL_RANGE * 2) - BASIC_SKILL_RANGE)
    rain.global_position = Vector2(pos_x, following_camera.get_top_pos_y())

    if count < BASIC_SKILL_RAIN_COUNT:
        var rain_timer = cd_timer.new(basic_skill_interval, self, "basic_skill_rains", count + 1)
        hero.register_timer("interruptable_skill", rain_timer)

# Shoot 5 consecutive bullets in a straight line.
func horizontal_skill(side):
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.change_sprite_facing(side)
        hero.play_animation("Horizontal Skill")

        hero.set_status("animate_movement", false, HORIZONTAL_SKILL_SHOOT_TIME)
        hero.set_status("can_move", false, HORIZONTAL_SKILL_SHOOT_TIME)
        hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_SHOOT_TIME + HORIZONTAL_SKILL_COOLDOWN)

        horizontal_skill_count = 0
        var shoot_timer = cd_timer.new(HORIZONTAL_SKILL_SHOOT_TIME, self, "horizontal_skill_shoot", side)
        hero.register_timer("interruptable_skill", shoot_timer)

func horizontal_skill_shoot(side):
    hero.unregister_timer("interruptable_skill")

    var bullet = horizontal_skill_letter.instance()
    bullet.initialize(side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size, horizontal_skill_count)
    spawn_node.add_child(bullet)
    bullet.global_position = horizontal_skill_spawn_pos.global_position

    horizontal_skill_count += 1
    if horizontal_skill_count < HORIZONTAL_SKILL_SHOOT_COUNT:
        hero.set_status("animate_movement", false, HORIZONTAL_SKILL_SHOOT_INTERVAL)
        hero.set_status("can_move", false, HORIZONTAL_SKILL_SHOOT_INTERVAL)
        hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_SHOOT_INTERVAL + HORIZONTAL_SKILL_COOLDOWN)
        
        var shoot_timer = cd_timer.new(HORIZONTAL_SKILL_SHOOT_INTERVAL, self, "horizontal_skill_shoot", side)
        hero.register_timer("interruptable_skill", shoot_timer)
    else:
        # Ending animation.
        hero.set_status("animate_movement", false, HORIZONTAL_SKILL_ENDING_DURATION)
        hero.set_status("can_move", false, HORIZONTAL_SKILL_ENDING_DURATION)
        hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_ENDING_DURATION + HORIZONTAL_SKILL_COOLDOWN)

# Double jumps.
func up_skill():
    if up_skill_available && hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Up Skill")

        if !hero.is_on_floor():
            var p = up_skill_puff.instance()
            spawn_node.add_child(p)
            p.global_position = up_skill_puff_spawn_pos.global_position

        hero.set_status("can_jump", false, UP_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, UP_SKILL_DURATION)
        hero.set_status("animate_movement", false,  UP_SKILL_DURATION)

        hero.jump_to_height(UP_SKILL_DISPLACEMENT)

        var jump_timer = cd_timer.new(UP_SKILL_SECOND_JUMP_TIME, self, "double_jumps")
        hero.register_timer("interruptable_skill", jump_timer)

func double_jumps():
    hero.unregister_timer("interruptable_skill")
    hero.jump_to_height(UP_SKILL_DISPLACEMENT)

# Heals.
func down_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Down Skill")

        hero.set_status("animate_movement", false, DOWN_SKILL_DURATION)
        hero.set_status("can_move", false, DOWN_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, DOWN_SKILL_DURATION + DOWN_SKILL_COOLDOWN)

        var heal_timer = cd_timer.new(DOWN_SKILL_HEAL_TIME, self, "down_skill_cast")
        hero.register_timer("interruptable_skill", heal_timer)

func down_skill_cast():
    hero.unregister_timer("interruptable_skill")

    hero.healed(DOWN_SKILL_HEAL_AMOUNT)

func ult():
    if hero.status.can_move && hero.status.has_ult && hero.status.can_cast_skill:
        hero.status.has_ult = false

        hero.set_status("can_move", false, ULT_DURATION)
        hero.set_status("can_jump", false, ULT_DURATION)
        hero.set_status("can_cast_skill", false, ULT_DURATION)
        hero.set_status("animate_movement", false, ULT_DURATION)
        hero.set_status("invincible", true, ULT_DURATION)

        hero.play_animation("Ult")
        ult_timer = cd_timer.new(ULT_START_RAIN_TIME, self, "ult_rains", 0)

func ult_rains(count):
    var rain = ult_rain.instance()
    rain.initialize(hero.attack_modifier, hero.size)
    spawn_node.add_child(rain)
    var pos_x = rng.randf_range(following_camera.get_camera_left_bound(), following_camera.get_camera_right_bound())
    var pos_y = following_camera.get_top_pos_y()
    rain.global_position = Vector2(pos_x, pos_y)

    if count < ULT_RAIN_COUNT:
        ult_timer = cd_timer.new(ult_interval, self, "ult_rains", count + 1)
    else:
        hero.release_ult()

func cancel_all_skills():
    pass