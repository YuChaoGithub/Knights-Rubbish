extends Node2D

export(int) var activate_range_x = 2000
export(int) var activate_range_y = 2000
export(int, "Dwarf", "Normal", "Giant") var change_to = 1

var activated = false

onready var hero_layer = ProjectSettings.get_setting("layer_names/2d_physics/hero")
onready var hero_manager = $"../../HeroManager"

func _ready():
	$TriggerArea.connect("area_entered", self, "hero_enter")

func _process(delta):
	if activated:
		pass
	elif hero_manager.in_range_of(global_position, activate_range_x, activate_range_y):
		activated = true
		$Particles2D.emitting = true
		$TriggerArea.set_collision_mask_bit(hero_layer, true)

func hero_enter(area):
	if area.is_in_group("hero"):
		var hero = area.get_node("..")
		if hero.size_status != change_to:
			hero.change_to_size(change_to)			