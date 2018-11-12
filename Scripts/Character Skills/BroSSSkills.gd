extends Node2D

# All brothers' information. (0: Sug, 1: Sir, 2. BigBro)
const JUMP_HEIGHT = 300.0
const MOVEMENT_SPEEDS = [350.0, 250.0, 450.0]
const JUMP_TIMES = [0.5, 0.6, 0.7]
const ANIMATORS = ["SugAnimator", "SirAnimator", "BigBrotherAnimator"]
onready var char_nodes = [
    $"../Sprite/Animation/Sug",
    $"../Sprite/Animation/Sir",
    $"../Sprite/Animation/Big Bro"
]
var hurt_sounds = [
    preload("res://Audio/bross_sug_hurt.wav"),
    preload("res://Audio/bross_sir_hurt.wav"),
    preload("res://Audio/bross_sir_hurt.wav")
]
var jump_sounds = [
    preload("res://Audio/bross_sug_jump.wav"),
    preload("res://Audio/bross_sir_jump.wav"),
    preload("res://Audio/bross_bro_jump.wav")
]
var size_change_sounds = [
    preload("res://Audio/bross_sug_size_change.wav"),
    preload("res://Audio/bross_sir_size_change.wav"),
    preload("res://Audio/bross_sir_size_change.wav")
]
var healed_sounds = [
    preload("res://Audio/bross_sug_healed.wav"),
    preload("res://Audio/bross_sir_healed.wav"),
    preload("res://Audio/bross_sir_healed.wav")
]
enum {SUG, SIR, BRO}
var curr_char = SUG

# Basic Attack.
const BASIC_ATTACK_DURATION = 0.8
const SIR_BASIC_ATTACK_THROW_TIME = 0.5
const BASIC_ATTACK_COOLDOWN = 0.15
const BASIC_ATTACK_DAMAGE_MIN = 30
const BASIC_ATTACK_DAMAGE_MAX = 45
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
const BASIC_SKILL_DAMAGE_MAX = 6
const BASIC_SKILL_HEAL_MIN = 1
const BASIC_SKILL_HEAL_MAX = 3
const BASIC_SKILL_SLOW_DURATION = 3.0
const BASIC_SKILL_SLOW_RATE = 0.5
const BASIC_SKILL_SPEED_DURATION = 6.0
const BASIC_SKILL_SPEED_RATE = 1.5

var basic_skill_targets = []

# Horizontal Skill.
const SUG_HORIZONTAL_SKILL_DURATION = 0.4
const SUG_HORIZONTAL_DASH_TIME = 0.2
const SUG_HORIZONTAL_SKILL_COOLDOWN = 0.15
const HORIZONTAL_SKILL_DAMAGE_MIN = 30
const HORIZONTAL_SKILL_DAMAGE_MAX = 45
const SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_X = 800
const SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_Y = 50
const SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_FADE_RATE = 1000
const SUG_HORIZONTAL_SKILL_KNOCK_BACK_VEL_X = 600
const SUG_HORIZONTAL_SKILL_KNOCK_BACK_VEL_Y = 50
const SUG_HORIZONTAL_SKILL_KNOCK_BACK_FADE_RATE = 1000
const SIR_HORIZONTAL_SKILL_DURATION = 1.0
const SIR_HORIZONTAL_SKILL_COOLDOWN = 0.15
const SIR_HORIZONTAL_SKILL_SHOOT_TIME = 0.6
const SIR_HORIZONTAL_SKILL_DISPLACEMENT_VEL_X = 700
const SIR_HORIZONTAL_SKILL_DISPLACEMENT_VEL_Y = 700
const SIR_HORIZONTAL_SKILL_DISPLACEMENT_FADE_RATE = 1000

var sir_horizontal_skill_bullet = preload("res://Scenes/Characters/Bro SS/SirHorizontalSkill.tscn")

# Down Skill.
const DOWN_SKILL_DURATION = 1.5
const DOWN_SKILL_SHOW_OTHER_CHAR_TIME = 1.1
const DOWN_SKILL_COOLDOWN = 0.3

var down_skill_show_timer
var transform_timer

# Up Skill.
const UP_SKILL_DURATION = 0.7
const UP_SKILL_COOLDOWN = 0.2
const UP_SKILL_DISPLACEMENT = 150
const UP_SKILL_DAMAGE_MIN = 30
const UP_SKILL_DAMAGE_MAX = 45
const UP_SKILL_KNOCK_BACK_VEL_X = 300
const UP_SKILL_KNOCK_BACK_VEL_Y = 200
const UP_SKILL_KNOCK_BACK_FADE_RATE = 300
const UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC = 250

onready var up_skill_particles_spawn_pos = $"../Sprite/Animation/UpSkillParticlesSpawnPos"
onready var up_skill_puff_spawn_pos = $"../Sprite/UpSkillPuffSpawnPos"
var up_skill_puff = preload("res://Scenes/Particles/UpSkillPuffParticles.tscn")

var up_skill_targets = []
var up_skill_available = true
var up_skill_available_timer = null
var up_skill_timestamp = 0

# Ult.
const ULT_TRANSFORM_DURATION = 1.5
const ULT_DURATION = 12.0
const END_ULT_DURATION = 1.5
const ULT_DAMAGE_MIN = 135
const ULT_DAMAGE_MAX = 140
const ULT_KNOCK_BACK_VEL_X = 600
const ULT_KNOCK_BACK_VEL_Y = 50
const ULT_KNOCK_BACK_FADE_RATE = 1000

var ult_start_explosion_particles = preload("res://Scenes/Particles/BroSSUltStartExplosion.tscn")
var ult_explosion_particles = preload("res://Scenes/Particles/BroSSUltExplosion.tscn")

var ult_timer
var char_before_ult

onready var bro_appear_audio = $"../Audio/BroAppear"
onready var bro_exit_audio = $"../Audio/BroExit"
onready var bro_background_audio = $"../Audio/BroBackground"

onready var hero = get_node("..")
onready var spawn_node = get_node("../..")

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var rng = preload("res://Scripts/Utils/RandomNumberGenerator.gd")

onready var audios_to_stop_when_stunned = [
    $"../Audio/SirBASpin",
    $"../Audio/SirBAToss",
    $"../Audio/SirBSSong",
    $"../Audio/SirHSLean",
    $"../Audio/SirHSShoot",
    $"../Audio/SirUS",
    $"../Audio/SugBA",
    $"../Audio/SugBSSong",
    $"../Audio/SugHSDash",
    $"../Audio/SugUS",
    $"../Audio/Drink"
]

func _ready():
    configure_char_visibility()
    hero.connect("did_jump", self, "reset_up_skill_available")

func configure_char_visibility():
    for index in range(char_nodes.size()):
        char_nodes[index].visible = (true if index == curr_char else false)

func _process(delta):
    if hero.is_on_floor():
        if !up_skill_available && OS.get_ticks_msec() - up_skill_timestamp > UP_SKILL_LANDING_DETECTION_DELAY_IN_MSEC && up_skill_available_timer == null:
            up_skill_available_timer = cd_timer.new(UP_SKILL_COOLDOWN, self, "reset_up_skill_available")

func reset_up_skill_available():
    up_skill_available = true

    if up_skill_available_timer != null:
        up_skill_available_timer.destroy_timer()
        up_skill_available_timer = null

# Basic Attack:
# Sug: Wields Sir, dealing damage, stunning enemies.
# Sir: Throws Sug, dealing damage.
func basic_attack():
    if curr_char != BRO && hero.status.can_move && hero.status.can_cast_skill:
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
        enemy.damaged(int(rng.randi_range(BASIC_ATTACK_DAMAGE_MIN, BASIC_ATTACK_DAMAGE_MAX) * hero.attack_modifier))

func sir_basic_attack_shoots():
    var sug = sir_basic_attack_sug.instance()
    sug.initialize(hero.side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
    spawn_node.add_child(sug)
    sug.global_position = sir_basic_attack_spawn_pos.global_position

    hero.unregister_timer("interruptable_skill")

# Basic Skill:
# Sug: Play music, deal damage and slow surrounding enemies.
# Sir: Play music, heal and speed up surrounding heroes.
func basic_skill():
    if curr_char != BRO && hero.status.can_move && hero.status.can_cast_skill:
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

# Horizontal Skill:
# Sug: Dash forward and attack.
# Sir: Shoot and hop backwards.
func horizontal_skill(side):
    if curr_char != BRO && hero.status.can_move && hero.status.can_cast_skill:
        hero.change_sprite_facing(side)

        hero.play_animation("Horizontal Skill")

        if curr_char == SUG:
            hero.set_status("animate_movement", false, SUG_HORIZONTAL_SKILL_DURATION)
            hero.set_status("can_move", false, SUG_HORIZONTAL_SKILL_DURATION)
            hero.set_status("can_cast_skill", false, SUG_HORIZONTAL_SKILL_DURATION + SUG_HORIZONTAL_SKILL_COOLDOWN)

            var attack_timer = cd_timer.new(SUG_HORIZONTAL_DASH_TIME, self, "sug_horizontal_skill_dashes", side)
            hero.register_timer("interruptable_skill", attack_timer)
        else:
            hero.set_status("animate_movement", false, SIR_HORIZONTAL_SKILL_DURATION)
            hero.set_status("can_move", false, SIR_HORIZONTAL_SKILL_DURATION)
            hero.set_status("can_cast_skill", false, SIR_HORIZONTAL_SKILL_DURATION + SIR_HORIZONTAL_SKILL_COOLDOWN)

            var shoot_timer = cd_timer.new(SIR_HORIZONTAL_SKILL_SHOOT_TIME, self, "sir_horizontal_skill_shoots", side)
            hero.register_timer("interruptable_skill", shoot_timer)

func sug_horizontal_skill_dashes(side):
    hero.knocked_back(side * SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_X, -SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_Y, SUG_HORIZONTAL_SKILL_DISPLACEMENT_VEL_FADE_RATE)
    hero.unregister_timer("interruptable_skill")

func sug_horizontal_skill_hit(area):
    if area.is_in_group("enemy"):
        var p = sug_basic_attack_particles.instance()
        spawn_node.add_child(p)
        p.global_position = sug_basic_attack_particles_spawn_pos.global_position

        var enemy = area.get_node("../..")
        enemy.knocked_back(sign(enemy.global_position.x - self.global_position.x) * SUG_HORIZONTAL_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -SUG_HORIZONTAL_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, SUG_HORIZONTAL_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy.damaged(int(rng.randf_range(HORIZONTAL_SKILL_DAMAGE_MIN, HORIZONTAL_SKILL_DAMAGE_MAX) * hero.attack_modifier))

func sir_horizontal_skill_shoots(side):
    var bullet = sir_horizontal_skill_bullet.instance()
    bullet.initialize(side, hero.attack_modifier, hero.enemy_knock_back_modifier, hero.size)
    spawn_node.add_child(bullet)
    bullet.global_position = sir_basic_attack_spawn_pos.global_position

    hero.knocked_back(-side * SIR_HORIZONTAL_SKILL_DISPLACEMENT_VEL_X, -SIR_HORIZONTAL_SKILL_DISPLACEMENT_VEL_Y, SIR_HORIZONTAL_SKILL_DISPLACEMENT_FADE_RATE)
    hero.unregister_timer("interruptable_skill")

# Up Skill: Jump and deal damage upwards.
func up_skill():
    if up_skill_available && hero.status.can_move && hero.status.can_cast_skill:
        hero.play_animation("Up Skill")

        if !hero.is_on_floor():
            var p = up_skill_puff.instance()
            spawn_node.add_child(p)
            p.global_position = up_skill_puff_spawn_pos.global_position

        up_skill_available = false
        up_skill_timestamp = OS.get_ticks_msec()

        up_skill_targets.clear()

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
        var enemy = area.get_node("../..")
        if !(enemy in up_skill_targets):
            var p = sug_basic_attack_particles.instance()
            spawn_node.add_child(p)
            p.global_position = up_skill_particles_spawn_pos.global_position

            up_skill_targets.push_back(enemy)

            enemy.damaged(int(rng.randi_range(UP_SKILL_DAMAGE_MIN, UP_SKILL_DAMAGE_MAX) * hero.attack_modifier))
            enemy.knocked_back(sign(enemy.global_position.x - self.global_position.x) * UP_SKILL_KNOCK_BACK_VEL_X * hero.enemy_knock_back_modifier, -UP_SKILL_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, UP_SKILL_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)

# Down Skill: Switch between sug and sir. Invincible while switching.
func down_skill():
    if curr_char != BRO && hero.status.can_move && hero.status.can_cast_skill:
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

    # Audio.
    hero.audio_players.hurt.stream = hurt_sounds[index]
    hero.audio_players.jump.stream = jump_sounds[index]
    hero.audio_players.size_change.stream = size_change_sounds[index]
    hero.audio_players.healed.stream = healed_sounds[index]

    var prev_animator = hero.animator
    hero.animator = hero.get_node(ANIMATORS[index])
    configure_char_visibility()
    prev_animator.play("Still")

func ult():
    if curr_char != BRO && hero.status.can_move && hero.status.can_cast_skill && hero.status.has_ult:
        hero.status.has_ult = false
        
        hero.set_status("can_move", false, ULT_TRANSFORM_DURATION)
        hero.set_status("can_jump", false, ULT_TRANSFORM_DURATION)
        hero.set_status("can_cast_skill", false, ULT_TRANSFORM_DURATION)
        hero.set_status("animate_movement", false, ULT_TRANSFORM_DURATION)
        hero.set_status("invincible", true, ULT_TRANSFORM_DURATION)

        hero.play_animation("Ult")
        hero.release_ult()

        char_before_ult = curr_char
        curr_char = BRO
        ult_timer = cd_timer.new(ULT_TRANSFORM_DURATION, self, "ult_transformed")

func ult_transformed():
    var p = ult_start_explosion_particles.instance()
    spawn_node.add_child(p)
    p.global_position = self.global_position

    transform_character(curr_char)

    bro_appear_audio.play()
    bro_background_audio.play()

    hero.set_status("invincible", true, ULT_DURATION)

    ult_timer = cd_timer.new(ULT_DURATION, self, "ult_ending")

func ult_ending():
    hero.play_animation("End Ult")

    bro_exit_audio.play()
    bro_background_audio.stop()

    hero.set_status("can_move", false, END_ULT_DURATION)
    hero.set_status("can_jump", false, END_ULT_DURATION)
    hero.set_status("can_cast_skill", false, END_ULT_DURATION)
    hero.set_status("animate_movement", false, END_ULT_DURATION)
    hero.set_status("invincible", true, END_ULT_DURATION)
    hero.set_status("no_movement", true, END_ULT_DURATION)

    ult_timer = cd_timer.new(END_ULT_DURATION, self, "ult_ended")

func ult_ended():
    var p = ult_explosion_particles.instance()
    spawn_node.add_child(p)
    p.global_position = self.global_position

    curr_char = char_before_ult
    transform_character(curr_char)

func ult_hit(area):
    if area.is_in_group("enemy"):
        var enemy = area.get_node("../..")
        enemy.knocked_back(sign(enemy.global_position.x - self.global_position.x) * hero.enemy_knock_back_modifier * ULT_KNOCK_BACK_VEL_X, -ULT_KNOCK_BACK_VEL_Y * hero.enemy_knock_back_modifier, ULT_KNOCK_BACK_FADE_RATE * hero.enemy_knock_back_modifier)
        enemy.damaged(int(rng.randf_range(ULT_DAMAGE_MIN, ULT_DAMAGE_MAX) * hero.attack_modifier))

func cancel_all_skills():
    pass