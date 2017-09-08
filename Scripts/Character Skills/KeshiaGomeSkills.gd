extends Node2D

const SKILL_COOL_DOWN = 1.0

# To get the "can_move" variable.
onready var character_node = get_node("..")

func basic_attack():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Basic Attack")
	
func left_attack():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Left Attack")
	
func right_attack():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Right Attack")
	
func up_attack():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Up Attack")
	
func down_attack():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Down Attack")
	
func basic_skill():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Basic Skill")
	
func left_skill():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Left Skill")
	
func right_skill():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Right Skill")
	
func up_skill():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Up Skill")
	
func down_skill():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("Down Skill")
	
func ult():
	character_node.can_move = false
	character_node.reset_can_move_after_time(SKILL_COOL_DOWN)
	print("ult")