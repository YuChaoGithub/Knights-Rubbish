extends Node2D

# Basic Attack
const BASIC_ATTACK_DURATION = 0.85
const BASIC_ATTACK_COOLDOWN = 0.1
const BASIC_ATTACK_DAMAGE = 50
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

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")

var strike_timer = null

onready var hero = $".."
onready var spawn_node = $"../.."

var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

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
        var p = basic_attack_hit_particles.instance()
        spawn_node.add_child(p)
        p.global_position = basic_attack_particles_spawn_pos.global_position

        var enemy_node = area.get_node("../..")
        enemy_node.knocked_back(sign(enemy_node.global_position.x - global_position.x) * BASIC_ATTACK_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_ATTACK_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy_node.damaged(int(BASIC_ATTACK_DAMAGE * hero.attack_modifier))

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
        enemy.knocked_back(sign(enemy.global_position.x - global_position.x) * BASIC_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy.damaged(int(BASIC_SKILL_DAMAGE * hero.attack_modifier))

func horizontal_skill(side):
    pass

func up_skill():
    pass

func down_skill():
    pass

func ult():
    pass

func cancel_all_skills():
    pass