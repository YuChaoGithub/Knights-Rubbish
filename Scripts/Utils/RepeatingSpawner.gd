extends Node2D

export(String, FILE) var mob_path
export(int) var activate_range_x = 3000
export(int) var activate_range_y = 3000
export(float) var spawn_delay = 0.75
export(int) var total_count

const MOB_FADE_IN_DURATION = 0.5
const PARTICLE_DURATION = 1.0

var curr_count = 0
var stopped = false
var timer = null
var curr_particle
var particle_timer
var prev_mob

var cd_timer = preload("res://Scripts/Utils/CountdownTimer.gd")
var opacity_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")
var spawning_particle = preload("res://Scenes/Particles/Spawn Mob Particles.tscn")

onready var mob_to_spawn = load(mob_path)
onready var spawn_pos = $".."

# Will be emitted when the last spawned mob is defeated.
signal completed

# Call this function to spawn the first mob.
func spawn_mob():
    if stopped:
        return

    curr_particle = spawning_particle.instance()
    add_child(curr_particle)
    particle_timer = cd_timer.new(PARTICLE_DURATION + spawn_delay, curr_particle, "queue_free")

    timer = cd_timer.new(spawn_delay, self, "actually_spawn")

func actually_spawn():
    var new_mob = mob_to_spawn.instance()
    new_mob.activate_range_x = activate_range_x
    new_mob.activate_range_y = activate_range_y
    new_mob.modulate.a = 0.0
    spawn_pos.add_child(new_mob)

    var new_alpha_lerper = opacity_lerper.instance()
    new_alpha_lerper.initialize(0.0, 1.0, MOB_FADE_IN_DURATION)
    new_mob.add_child(new_alpha_lerper)
    new_mob.global_position = global_position

    curr_count += 1
    if curr_count == total_count || stopped:
        new_mob.connect("defeated", self, "complete_spawning")
    else:
        new_mob.connect("defeated", self, "spawn_mob")

    prev_mob = weakref(new_mob)

func complete_spawning():
    emit_signal("completed")

func stop_further_spawning():
    stopped = true

    var mob = prev_mob.get_ref()
    if mob != null:
        mob.connect("defeated", self, "complete_spawning")