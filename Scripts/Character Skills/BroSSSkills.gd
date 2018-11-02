extends Node2D

# All brothers' information. (0: Sug, 1: Sir, 2. BigBro)
const JUMP_HEIGHT = 300.0
const MOVEMENT_SPEEDS = [350.0, 250.0, 450.0]
const JUMP_TIMES = [0.4, 0.6, 0.8]
const ANIMATORS = ["SugAnimator", "SirAnimator", "BigBrotherAnimator"]
onready var char_nodes = [
    $"../Sprite/Animation/Sug",
    $"../Sprite/Animation/Sir",
    $"../Sprite/Animation/Big Bro"
]
enum {SUG, SIR, BRO}
var curr_char = SUG

# Basic Attack.
const BASIC_ATTACK_DURATION = 0.8
const SIR_BASIC_ATTACK_THROW_TIME = 0.5
const BASIC_ATTACK_COOLDOWN = 0.15
const BASIC_ATTACK_DAMAGE_MIN = 40
const BASIC_ATTACK_DAMAGE_MAX = 60
const BASIC_ATTACK_STUN_DURATION = 0.5
const BASIC_ATTACK_KNOCK_BACK_VEL_X = 300
const BASIC_ATTACK_KNOCK_BACK_VEL_Y = 50
const BASIC_ATTACK_KNOCK_BACK_FADE_RATE = 600

var sug_basic_attack_particles = preload("res://Scenes/Particles/SugBasicAttackParticles.tscn")
onready var sug_basic_attack_particles_spawn_pos = $"../Sprite/Animation/Sug/Sir/SugBasicAttackParticlesSpawnPos"

var sir_basic_attack_sug = preload("res://Scenes/Characters/Bro SS/SirBasicAttack.tscn")
onready var sir_basic_attack_spawn_pos = $"../Sprite/Animation/Sir/Sug"

# Basic Skill.
const BASIC_SKILL_DURATION = 3.0
const BASIC_SKILL_COOLDOWN = 0.2
const BASIC_SKILL_DAMAGE_MIN = 2
const BASIC_SKILL_DAMAGE_MAX = 5
const BASIC_SKILL_HEAL_MIN = 1
const BASIC_SKILL_HEAL_MAX = 3
const BASIC_SKILL_SLOW_DURATION = 3.0
const BASIC_SKILL_SLOW_RATE = 0.5
const BASIC_SKILL_SPEED_DURATION = 6.0
const BASIC_SKILL_SPEED_RATE = 1.5

var basic_skill_targets = []

# Down Skill.
const DOWN_SKILL_DURATION = 1.5
const DOWN_SKILL_SHOW_OTHER_CHAR_TIME = 1.1
const DOWN_SKILL_COOLDOWN = 0.3

var down_skill_show_timer
var transform_timer

onready var hero = get_node("..")
onready var spawn_node = get_node("../..")

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

func _ready():
    configure_char_visibility()

func configure_char_visibility():
    for index in range(char_nodes.size()):
        char_nodes[index].visible = (true if index == curr_char else false)

func _process(delta):
    pass

# Sug: Wields Sir, dealing damage, stunning enemies.
# Sir: Throws Sug, dealing damage.
func basic_attack():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Attack")

        hero.set_status("animate_movement", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_move", false, BASIC_ATTACK_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_ATTACK_DURATION + BASIC_ATTACK_COOLDOWN)

        var attack_func_name = "sug_basic_attack_ended" if curr_char == SUG else "sir_basic_attack_shoots"
        var duration = BASIC_ATTACK_DURATION if curr_char == SUG else SIR_BASIC_ATTACK_THROW_TIME
        var attack_timer = cd_timer.new(duration, self, attack_func_name)
        hero.register_timer("interruptable_skill", attack_timer)

func sug_basic_attack_ended():
    hero.unregister_timer("interruptable_skill")

func sug_basic_attack_hit(area):
    if area.is_in_group("enemy"):
        var p = sug_basic_attack_particles.instance()
        spawn_node.add_child(p)
        p.global_position = sug_basic_attack_particles_spawn_pos.global_position

        var enemy = area.get_node("../..")
        enemy.knocked_back(sign(enemy.global_position.x - self.global_position.x) * BASIC_ATTACK_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -BASIC_ATTACK_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, BASIC_ATTACK_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy.stunned(BASIC_ATTACK_STUN_DURATION)
        enemy.damaged(int(rng.randi_range(BASIC_ATTACK_DAMAGE_MIN, BASIC_ATTACK_DAMAGE_MAX) * hero.attack_modifier))

func sir_basic_attack_shoots():
    var sug = sir_basic_attack_sug.instance()
    sug.initialize(hero.side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
    spawn_node.add_child(sug)
    sug.global_position = sir_basic_attack_spawn_pos.global_position

    hero.unregister_timer("interruptable_skill")

# Sug: Play music, deal damage and slow surrounding enemies.
# Sir: Play music, heal and speed up surrounding heroes.
func basic_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Basic Skill")

        hero.set_status("animate_movement", false, BASIC_SKILL_DURATION)
        hero.set_status("can_move", false, BASIC_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, BASIC_SKILL_DURATION + BASIC_SKILL_COOLDOWN)

        basic_skill_targets.clear()

        var skill_timer = cd_timer.new(BASIC_SKILL_DURATION, self, "basic_skill_ended")
        hero.register_timer("interruptable_skill", skill_timer)

func basic_skill_ended():
    hero.unregister_timer("interruptable_skill")

func sug_basic_skill_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        if !(enemy in basic_skill_targets):
            enemy.slowed(BASIC_SKILL_SLOW_RATE, BASIC_SKILL_SLOW_DURATION)
            basic_skill_targets.push_back(enemy)

        enemy.damaged(int(rng.randi_range(BASIC_SKILL_DAMAGE_MIN, BASIC_SKILL_DAMAGE_MAX) * hero.attack_modifier))

func sir_basic_skill_hit(area):
    if area.is_in_group("hero"):
        var target_hero = area.get_node("..")
        if !(target_hero in basic_skill_targets):
            var args = {
                multiplier = BASIC_SKILL_SPEED_RATE,
                duration = BASIC_SKILL_SPEED_DURATION
            }
            target_hero.speed_changed(args)
            basic_skill_targets.push_back(target_hero)

        target_hero.healed(rng.randi_range(BASIC_SKILL_HEAL_MIN, BASIC_SKILL_HEAL_MAX))

func horizontal_skill(side):
    pass

func up_skill():
    pass

# Down Skill: Switch between sug and sir. Invincible while switching.
func down_skill():
    if hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Down Skill")

        hero.set_status("can_move", false, DOWN_SKILL_DURATION)
        hero.set_status("animate_movement", false, DOWN_SKILL_DURATION)
        hero.set_status("can_cast_skill", false, DOWN_SKILL_DURATION + DOWN_SKILL_COOLDOWN)
        hero.set_status("invincible", true, DOWN_SKILL_DURATION)
    
        curr_char = (SIR if curr_char == SUG else SUG)
        down_skill_show_timer = cd_timer.new(DOWN_SKILL_SHOW_OTHER_CHAR_TIME, self, "show_other_character", curr_char)
        transform_timer = cd_timer.new(DOWN_SKILL_DURATION, self, "transform_character", curr_char)

func show_other_character(index):
    char_nodes[index].visible = true

func transform_character(index):
    # Movement.
    hero.speed = MOVEMENT_SPEEDS[index] * hero.movement_speed_modifier
    hero.gravity = 2 * JUMP_HEIGHT / pow(JUMP_TIMES[index], 2)
    hero.jump_speed = -hero.gravity * JUMP_TIMES[index]

    var prev_animator = hero.animator
    hero.animator = hero.get_node(ANIMATORS[index])
    configure_char_visibility()
    prev_animator.play("Still")

func ult():
    pass

func cancel_all_skills():
    pass