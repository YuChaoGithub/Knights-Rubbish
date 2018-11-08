extends Node2D

# Basic Attack
const BASIC_ATTACK_DURATION = 0.85
const BASIC_ATTACK_COOLDOWN = 0.1
const BASIC_ATTACK_DAMAGE = 30
const BASIC_ATTACK_KNOCK_BACK_VEL_X = 300
const BASIC_ATTACK_KNOCK_BACK_VEL_Y = 50
const BASIC_ATTACK_KNOCK_BACK_FADE_RATE = 600

var basic_attack_hit_particles = preload("res://Scenes/Particles/RanawatoBasicAttackParticles.tscn")
onready var basic_attack_particles_spawn_pos = $"../Sprite/Animation/Spoon/BasicAttackParticlesSpawnPos"

# Basic Skill
const BASIC_SKILL_DURATION = 1.85
const BASIC_SKILL_COOLDOWN = 0.2
const BASIC_SKILL_DAMAGE = 40
const BASIC_SKILL_KNOCK_BACK_VEL_X = 500
const BASIC_SKILL_KNOCK_BACK_VEL_Y = 50
const BASIC_SKILL_KNOCK_BACK_FADE_RATE = 1000

# Down Skill
const START_INVINCIBLE_TIME = 0.8
const DOWN_SKILL_DURATION = 2.7
const DOWN_SKILL_COOLDOWN = 0.1

const UP_SKILL_DURATION = 1.3
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_DISPLACEMENT = 150
const UP_SKILL_DAMAGE = 20
const UP_SKILL_KNOCK_BACK_VEL_X = 300
const UP_SKILL_KNOCK_BACK_VEL_Y = 200
const UP_SKILL_KNOCK_BACK_FADE_RATE = 300
const UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC = 250

var up_skill_available = true
var up_skill_available_timer = null
var up_skill_timestamp = 0

var up_skill_puff = preload("res://Scenes/Particles/UpSkillPuffParticles.tscn")
onready var up_skill_puff_spawn_pos = $"../Sprite/Animation/UpSkillPuffSpawnPos"

# Horizontal Skill.
const HORIZONTAL_SKILL_TOSS_TIME = 0.7
const HORIZONTAL_SKILL_DURATION = 1.5
const HORIZONTAL_SKILL_COOLDOWN = 0.1
const HORIZONTAL_SKILL_DAMAGE = 60
const HORIZONTAL_SKILL_STUN_DURATION = 2.5
const HORIZONTAL_SKILL_HIT_DURATION = 0.3
var horizontal_skill_spoon = preload("res://Scenes/Characters/Ranawato Plato/RanawatoHorizontalSkillSpoon.tscn")
var horizontal_skill_blink_particles = preload("res://Scenes/Particles/RanawatoHorizontalBlinkParticles.tscn")
onready var horizontal_skill_spawn_pos = $"../Sprite/Animation/HorizontalSkillSpawnPos"

# Ult.
const ULT_DURATION = 3.5
const ULT_SHOOT_TIME = 1.5
const ULT_SHOOT_TOTAL_SPOONS = 50
const ULT_END_SHOOT_TIME = 3.0

var ult_spoon = preload("res://Scenes/Characters/Ranawato Plato/RanawatoUltSpoon.tscn")
var ult_interval
var ult_timer

onready var ult_toss_audio = $"../Audio/UltToss"

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var strike_timer = null

onready var hero = $".."
onready var spawn_node = $"../.."

func _ready():
    ult_interval = (ULT_END_SHOOT_TIME - ULT_SHOOT_TIME) / ULT_SHOOT_TOTAL_SPOONS
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

# Basic Attack: Wields spoon in a circular arc, dealing damage.
func basic_attack():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Attack")

        hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)

        strike_timer = cd_timer.new(BASIC_ATTACK_DURATION, self, "basic_attack_strikes")
        hero.register_timer("interruptable_skill", strike_timer)

func basic_attack_strikes():
    hero.unregister_timer("interruptable_skill")

func basic_attack_hit(area):
    if area.is_in_group("enemy"):
        spawn_spoon_particles()

        var enemy_node = area.get_node("../..")
        enemy_node.knocked_back(sign(enemy_node.global_position.x - global_position.x) * BASIC_ATTACK_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_ATTACK_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy_node.damaged(int(BASIC_ATTACK_DAMAGE * hero.attack_modifier))

func spawn_spoon_particles():
    var p = basic_attack_hit_particles.instance()
    spawn_node.add_child(p)
    p.global_position = basic_attack_particles_spawn_pos.global_position

# Throw two spoons out, dealing damage.
func basic_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Skill")

        hero.set_status("animate_movement", false, BASIC_SKILL_DURATION)
        hero.set_status("can_move", false, BASIC_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_SKILL_DURATION + BASIC_SKILL_COOLDOWN)
        hero.set_status("no_movement", true, BASIC_SKILL_DURATION)

        var strike_timer = cd_timer.new(BASIC_SKILL_DURATION, self, "basic_skill_strikes")
        hero.register_timer("interruptable_skill", strike_timer)

func basic_skill_strikes():
    hero.unregister_timer("interruptable_skill")

    # Ensure falling after skill.
    hero.velocity.y = 0.0
    hero.cancel_knock_back()

func basic_skill_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * BASIC_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy.damaged(int(BASIC_SKILL_DAMAGE * hero.attack_modifier))

# Horizontal Skill: Shoot a spoon. If it hits an enemy, teleport to the enemy and stun it.
func horizontal_skill(side):
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Horizontal Skill")
        hero.change_sprite_facing(side)

        hero.set_status("animate_movement", false, HORIZONTAL_SKILL_DURATION)
        hero.set_status("can_move", false, HORIZONTAL_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_DURATION + HORIZONTAL_SKILL_COOLDOWN)

        var shoot_timer = cd_timer.new(HORIZONTAL_SKILL_TOSS_TIME, self, "horizontal_skill_shoots", side)
        hero.register_timer("interruptable_skill", shoot_timer)

func horizontal_skill_shoots(side):
    var spoon = horizontal_skill_spoon.instance()
    spoon.initialize(side, hero.size, self)
    spawn_node.add_child(spoon)
    spoon.global_position = horizontal_skill_spawn_pos.global_position

    hero.unregister_timer("interruptable_skill")
    
    var blink_timer = cd_timer.new(HORIZONTAL_SKILL_DURATION - HORIZONTAL_SKILL_TOSS_TIME, self, "horizontal_skill_ended")
    hero.register_timer("interruptable_skill", blink_timer)

func horizontal_skill_ended():
    hero.unregister_timer("interruptable_skill")

func horizontal_skill_cancelled():
    hero.interrupt_skills()

func horizontal_skill_hit(enemy):
    hero.interrupt_skills()

    var p = horizontal_skill_blink_particles.instance()
    spawn_node.add_child(p)
    p.global_position = self.global_position
    
    enemy.stunned(HORIZONTAL_SKILL_STUN_DURATION)
    enemy.damaged(int(HORIZONTAL_SKILL_DAMAGE * hero.attack_modifier))

    hero.global_position = enemy.global_position

    hero.play_animation("Horizontal Skill Hit")
    hero.set_status("animate_movement", false, HORIZONTAL_SKILL_HIT_DURATION)
    hero.set_status("can_move", false, HORIZONTAL_SKILL_HIT_DURATION)
    hero.set_status("can_cast_skill", false, HORIZONTAL_SKILL_HIT_DURATION + HORIZONTAL_SKILL_COOLDOWN)
    hero.set_status("invincible", true, HORIZONTAL_SKILL_HIT_DURATION)

func up_skill():
    if up_skill_available && hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Up Skill")

        if !hero.is_on_floor():
            var p = up_skill_puff.instance()
            spawn_node.add_child(p)
            p.global_position = up_skill_puff_spawn_pos.global_position

        hero.set_status("can_jump", false, UP_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, UP_SKILL_DURATION)
        hero.set_status("animate_movement", false, UP_SKILL_DURATION)

        hero.jump_to_height(UP_SKILL_DISPLACEMENT)

        var jump_timer = cd_timer.new(UP_SKILL_DURATION, self, "up_skill_ended")
        hero.register_timer("interruptable_skill", jump_timer)

func up_skill_ended():
    hero.unregister_timer("interruptable_skill")

func up_skill_hit(area):
    if area.is_in_group("enemy"):
        spawn_spoon_particles()

        var enemy = area.get_node("../..")
        enemy.damaged(int(UP_SKILL_DAMAGE * hero.attack_modifier))
        enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * UP_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -UP_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, UP_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)

# After a short delay, become invisible.
func down_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Down Skill")

        hero.set_status("can_move", false, DOWN_SKILL_DURATION)
        hero.set_status("animate_movement", false, DOWN_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, DOWN_SKILL_DURATION + DOWN_SKILL_COOLDOWN)

        var invincible_timer = cd_timer.new(START_INVINCIBLE_TIME, self, "start_invincible")
        hero.register_timer("interruptable_skill", invincible_timer)

func start_invincible():
    hero.unregister_timer("interruptable_skill")

    hero.set_status("invincible", true, DOWN_SKILL_DURATION - START_INVINCIBLE_TIME)

func ult():
    if hero.status.can_move && hero.status.has_ult &&  hero.status.can_cast_skill:
        hero.status.has_ult = false

        hero.set_status("can_move", false, ULT_DURATION)
        hero.set_status("can_jump", false, ULT_DURATION)
        hero.set_status("can_cast_skill", false, ULT_DURATION)
        hero.set_status("animate_movement", false, ULT_DURATION)
        hero.set_status("invincible", true, ULT_DURATION)
        hero.set_status("no_movement", true, ULT_DURATION)

        hero.play_animation("Ult")
        ult_timer = cd_timer.new(ULT_SHOOT_TIME, self, "fire_ult", 0)

func fire_ult(curr_count):
    var spoon = ult_spoon.instance()
    spoon.initialize(hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
    spawn_node.add_child(spoon)
    spoon.global_position = self.global_position

    ult_toss_audio.play()

    if curr_count < ULT_SHOOT_TOTAL_SPOONS:
        ult_timer = cd_timer.new(ult_interval, self, "fire_ult", curr_count + 1)
    else:
        hero.release_ult()

func cancel_all_skills():
    pass