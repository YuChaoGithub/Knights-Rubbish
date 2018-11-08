extends Node2D

export(String, FILE) var enter_scene_path

const HERO_FADING_DURATION = 1.0

var parent_lerper = preload("res://Scenes/Utils/Parent Opacity Lerper.tscn")
var enter_door_audio = preload("res://Scenes/Characters/EnterDoorAudio.tscn")

onready var collision_area = $Collision/CollisionArea

func _ready():
	collision_area.add_to_group("enemy")

func break_open():
	collision_area.remove_from_group("enemy")
	collision_area.add_to_group("door")
	$Door/AnimationPlayer.play("Explode")

func hero_enter(hero):
	hero.status.can_move = false

	var a = enter_door_audio.instance()
	$"..".add_child(a)
	a.global_position = self.global_position

	var lerper = parent_lerper.instance()
	lerper.initialize(hero.modulate.a, 0.0, HERO_FADING_DURATION, self, "switch_scene")
	hero.add_child(lerper)

func switch_scene():
	var loading_scene = get_node("/root/LoadingScene")
	loading_scene.pop_curr_scene_from_stack()
	loading_scene.load_scene(enter_scene_path)

func damaged(val):
	break_open()

func stunned(duration):
	pass

func slowed(multiplier, duration):
	pass

func knocked_back(vel_x, vel_y, fade_rate):
	pass

func healed(val):
	pass