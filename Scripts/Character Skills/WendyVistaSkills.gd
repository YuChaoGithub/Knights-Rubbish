extends Node2D

const BASIC_ATTACK_SHOOT_TIME = 0.5
const BASIC_ATTACK_DURATION = 0.8
const BASIC_ATTACK_COOLDOWN = 0.2

const BASIC_SKILL_DURATION = 0.8
const BASIC_SKILL_COOLDOWN = 0.2
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
const UP_SKILL_LANDED_DETECTION_DELAY = 0.05
const UP_SKILL_VELOCITY = -850

const DOWN_SKILL_DURATION = 2.0
const DOWN_SKILL_COOLDOWN = 0.3

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

onready var hero = $".."
onready var basic_attack_shoot_pos = $"../Sprite/BasicAttackShootPos"
onready var basic_skill_particles = $"../Sprite/Animation/BasicSkillParticles"
onready var horizontal_skill_shoot_pos = $"../Sprite/HorizontalSkillShootPos"
onready var up_skill_hat_spawn_pos = $"../Sprite/UpSkillHatSpawnPos"
onready var spawn_node = get_node("../..")

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

var basic_attack_cd = preload("res://Scenes/Characters/Wendy Vista/Basic Attack CD.tscn")
var horizontal_skill_cd = preload("res://Scenes/Characters/Wendy Vista/Horizontal Skill CD.tscn")

# Can only cast Up Skill one time until Wendy landed on the ground.
var up_skill_available = true
var up_skill_available_timer = null

func _ready():
    hero.connect("did_jump", self, "reset_up_skill_available")

func _process(delta):
    if hero.is_on_floor():
        if !up_skill_available && up_skill_available_timer == null:
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
    cd.initialize(hero.side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.scale.x)

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
    cd.initialize(side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.scale.x)

    spawn_node.add_child(cd)
    cd.global_position = horizontal_skill_shoot_pos.global_position

    hero.unregister_timer("interruptable_skill")

# ===
# Up Skill: Throw the hat up and jump.
# ===
func up_skill():
    pass

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
    pass

func cancel_all_skills():
    pass