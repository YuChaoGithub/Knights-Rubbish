extends Node2D

const MAX_COUNT = 5
const OFFSET_Y = 75

# A queue.
var numbers = [null, null, null, null, null]

func get_curr_pos(number):
    var available_slot = 0
    for i in range(numbers.size()):
        if numbers[i] == null || numbers[i].get_ref() == null:
            available_slot = i
            break
    
    var res_y = get_global_pos().y - available_slot * OFFSET_Y
    numbers[available_slot] = weakref(number)
    return Vector2(get_global_pos().x, res_y)