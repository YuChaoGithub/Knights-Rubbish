extends Node2D

# Basic Attack.
const BASIC_ATTACK_DURATION = 3.0
const BASIC_ATTACK_COOLDOWN = 0.1
const BASIC_ATTACK_DAMAGE_MIN = 45
const BASIC_ATTACK_DAMAGE_MAX = 65
const BASIC_ATTACK_KNOCK_BACK_VEL_X = 500
const BASIC_ATTACK_KNOCK_BACK_VEL_Y = 50
const BASIC_ATTACK_KNOCK_BACK_FADE_RATE = 1000
const BASIC_ATTACK_STUN_DURATION = 1.5

# Basic Skill.
const BASIC_SKILL_DURATION = 3.0
const BASIC_SKILL_COOLDOWN = 0.15
const BASIC_SKILL_RAIN_TIME = 1.5
const BASIC_SKILL_RAIN_COUNT = 60
const BASIC_SKILL_RANGE = 600

# Horizontal Skill.
const HORIZONTAL_SKILL_ENDING_DURATION = 0.5
const HORIZONTAL_SKILL_COOLDOWN = 0.15
const HORIZONTAL_SKILL_SHOOT_TIME = 1.0
const HORIZONTAL_SKILL_SHOOT_INTERVAL = 0.5
const HORIZONTAL_SKILL_SHOOT_COUNT = 5

var horizontal_skill_count = 0
var horizontal_skill_letter = preload("res://Scenes/Characters/Othox Codox/OthoxHorizontalSkill.tscn")
onready var horizontal_skill_spawn_pos = $"../Sprite/Animation/HorizontalSkillShootPos"

var basic_skill_rain = preload("res://Scenes/Characters/Othox Codox/OthoxBasicSkillRain.tscn")
onready var following_camera = $"../../FollowingCamera"
var basic_skill_interval

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")
onready var hero = $".."
onready var spawn_node = $"../.."

func _ready():
    basic_skill_interval = (BASIC_SKILL_DURATION - BASIC_SKILL_RAIN_TIME) / BASIC_SKILL_RAIN_COUNT

# Basic Attack: Wields a word-sword.
func basic_attack():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Attack")

        hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)
        
        var strike_timer = cd_timer.new(BASIC_ATTACK_DURATION, self, "basic_attack_strikes")
        hero.register_timer("interruptable_skill", strike_timer)

func basic_attack_strikes():
    hero.unregister_timer("interruptable_skill")

func basic_attack_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
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
    rain.initialize(hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
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

func up_skill():
    pass

func down_skill():
    pass

func ult():
    pass

func cancel_all_skills():
    pass