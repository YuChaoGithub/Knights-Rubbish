extends Node2D

export(String, FILE) var mob_path
export(int) var total_count

var curr_count = 0

onready var mob_to_spawn = load(mob_path)
onready var spawn_pos = get_node("..")

signal completed

# Call this function to spawn the first mob.
func spawn_mob():
    var new_mob = mob_to_spawn.instance()
    spawn_pos.add_child(new_mob)
    new_mob.set_global_pos(get_global_pos())

    curr_count += 1
    if curr_count == total_count:
        new_mob.connect("defeated", self, "spawn_mob")
    else:
        new_mob.connect("defeated", self, "complete_spawning")

func complete_spawning():
    emit_signal("completed")