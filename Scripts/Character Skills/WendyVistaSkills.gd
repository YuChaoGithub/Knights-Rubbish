extends Node2D

const BASIC_ATTACK_SHOOT_TIME = 0.5
const BASIC_ATTACK_DURATION = 0.8
const BASIC_ATTACK_COOLDOWN = 0.2

const BASIC_SKILL_DURATION = 0.8
const BASIC_SKILL_COOLDOWN = 0.35
const BASIC_SKILL_DAMAGE_MIN = 5
const BASIC_SKILL_DAMAGE_MAX = 10
const BASIC_SKILL_KNOCK_BACK_VEL_X = 1200
const BASIC_SKILL_KNOCK_BACK_VEL_Y = 50
const BASIC_SKILL_KNOCK_BACK_FADE_RATE = 1400

const HORIZONTAL_SKILL_SHOOT_TIME = 1.0
const HORIZONTAL_SKILL_DURATION = 1.6
const HORIZONTAL_SKILL_COOLDOWN = 0.1

const UP_SKILL_DURATION = 0.7
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_DISPLACEMENT = 150
const UP_SKILL_DAMAGE_MIN = 10
const UP_SKILL_DAMAGE_MAX = 20
const UP_SKILL_KNOCK_BACK_VEL_X = 300
const UP_SKILL_KNOCK_BACK_VEL_Y = 250
const UP_SKILL_KNOCK_BACK_FADE_RATE = 300
const UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC = 250

const ULT_PREPARE_DURATION = 1.0
const ULT_FIRE_INTERVAL = 0.2
const ULT_FIRE_COUNT = 10
const ULT_ENDING_DURATION = 0.5

const DOWN_SKILL_DURATION = 2.0
const DOWN_SKILL_COOLDOWN = 0.3

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var multi_timer = preload("res://Scripts/Utils/MultiTickTimer.gd")

onready var hero = $".."
onready var basic_attack_shoot_pos = $"../Sprite/BasicAttackShootPos"
onready var basic_skill_particles = $"../Sprite/Animation/BasicSkillParticles"
onready var horizontal_skill_shoot_pos = $"../Sprite/HorizontalSkillShootPos"
onready var ult_skill_shoot_pos = $"../Sprite/Animation/Body/UltFirePos"
onready var spawn_node = get_node("../..")

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

var basic_attack_cd = preload("res://Scenes/Characters/Wendy Vista/Basic Attack CD.tscn")
var horizontal_skill_cd = preload("res://Scenes/Characters/Wendy Vista/Horizontal Skill CD.tscn")
var ult_cd = preload("res://Scenes/Characters/Wendy Vista/Wendy Ult CD.tscn")

# Can only cast Up Skill one time until Wendy landed on the ground.
var up_skill_available = true
var up_skill_available_timer = null
var up_skill_timestamp = 0

var ult_timer

func _ready():
    hero.connect("did_jump", self, "reset_up_skill_available")

func _process(delta):
    if hero.is_on_floor():
        if !up_skill_available && OS.get_ticks_msec() - up_skill_timestamp > UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC && up_skill_available_timer == null:
            up_skill_available_timer = cd_timer.new(UP_SKILL_COOLDOWN, self, "reset_up_skill_available")

func reset_up_skill_available():
    up_skill_available = true

    if up_skill_available_timer != null:
        up_skill_available_timer.destroy_timer()
        up_skill_available_timer = null

# ===
# Basic Attack: Throw a projectile stun, slow or knockback CD.
# ===
func basic_attack():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Attack")

        hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)

        var shoot_timer = cd_timer.new(BASIC_ATTACK_SHOOT_TIME, self, "basic_attack_shoots")
        hero.register_timer("interruptable_skill", shoot_timer)

func basic_attack_shoots():
    var cd = basic_attack_cd.instance()
    cd.initialize(hero.side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)

    spawn_node.add_child(cd)
    cd.global_position = basic_attack_shoot_pos.global_position

    hero.unregister_timer("interruptable_skill")
    
# ===
# Basic Skill: Knock back nearby enemies.
# ===
func basic_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Skill")
        basic_skill_particles.emitting = true
        
        hero.set_status("animate_movement", false, BASIC_SKILL_DURATION)
        hero.set_status("can_move", false, BASIC_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_SKILL_DURATION + BASIC_SKILL_COOLDOWN)
        hero.set_status("no_movement", true, BASIC_SKILL_DURATION)

        if hero.velocity.y < 0:
           hero.velocity.y *= -1

func basic_skill_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.damaged(hero.attack_modifier * rng.randi_range(BASIC_SKILL_DAMAGE_MIN, BASIC_SKILL_DAMAGE_MAX))
        enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * BASIC_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)

# ===
# Horizontal Skill: Shoot a piercing CD.
# ===
func horizontal_skill(side):
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Horizontal Skill")

        hero.set_status("animate_movement", false, HORIZONTAL_SKILL_DURATION)
        hero.set_status("can_move", false, HORIZONTAL_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_DURATION + HORIZONTAL_SKILL_COOLDOWN)

        var shoot_timer = cd_timer.new(HORIZONTAL_SKILL_SHOOT_TIME, self, "horizontal_skill_shoots", side)
        hero.register_timer("interruptable_skill", shoot_timer)

func horizontal_skill_shoots(side):
    var cd = horizontal_skill_cd.instance()
    cd.initialize(side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)

    spawn_node.add_child(cd)
    cd.global_position = horizontal_skill_shoot_pos.global_position

    hero.unregister_timer("interruptable_skill")

# ===
# Up Skill: Throw the hat up and jump.
# ===
func up_skill():
    if up_skill_available && hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Up Skill")

        up_skill_available = false
        up_skill_timestamp = OS.get_ticks_msec()

        hero.set_status("can_jump", false, UP_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, UP_SKILL_DURATION)
        hero.set_status("animate_movement", false, UP_SKILL_DURATION)

        hero.jump_to_height(UP_SKILL_DISPLACEMENT)

        var jump_timer = cd_timer.new(UP_SKILL_DURATION, self, "up_skill_ended")
        hero.register_timer("movement_skill", jump_timer)

func up_skill_ended():
    hero.unregister_timer("movement_skill")

func on_up_skill_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.damaged(int(rng.randi_range(UP_SKILL_DAMAGE_MIN, UP_SKILL_DAMAGE_MAX) * hero.attack_modifier))
        enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * UP_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -UP_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, UP_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)

# ===
# Down Skill: Shrink and hide in the hat.
# ===
func down_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Down Skill")

        hero.set_status("can_move", false, DOWN_SKILL_DURATION)
        hero.set_status("animate_movement", false, DOWN_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, DOWN_SKILL_DURATION + DOWN_SKILL_COOLDOWN) 
        hero.set_status("invincible", true, DOWN_SKILL_DURATION)

# ===
# Ult: Shoot consecutive high damage CDs.
# ===
func ult():
    if hero.status.can_move && hero.status.has_ult && hero.status.can_cast_skill:
        hero.status.has_ult = false

        var total_duration = ULT_PREPARE_DURATION + ULT_FIRE_COUNT * ULT_FIRE_INTERVAL + ULT_ENDING_DURATION
        hero.set_status("can_move", false, total_duration)
        hero.set_status("can_jump", false, total_duration)
        hero.set_status("can_cast_skill", false, total_duration)
        hero.set_status("animate_movement", false, total_duration)
        hero.set_status("invincible", true, total_duration)
        hero.set_status("no_movement", true, total_duration)

        hero.play_animation("Ult")
        hero.get_node("Ult").visible = true
        ult_timer = cd_timer.new(ULT_PREPARE_DURATION, self, "start_firing_ult")

func start_firing_ult():
    ult_timer = multi_timer.new(true, ULT_FIRE_INTERVAL, ULT_FIRE_COUNT, self, "fire_ult", null, "end_ult")

func fire_ult():
    var cd = ult_cd.instance()
    cd.initialize(hero.side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
    spawn_node.add_child(cd)
    cd.global_position = ult_skill_shoot_pos.global_position

func end_ult():
    hero.release_ult()
    hero.get_node("Ult").visible = false

func cancel_all_skills():
    pass