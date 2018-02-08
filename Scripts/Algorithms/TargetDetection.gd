# Return the nearest target from the given array.
static func get_nearest(from_node, targets):
    var min_distance = 1000000
    var min_distance_index = -1
    var from_pos = from_node.global_position

    for i in range(targets.size()):
        var distance_squared = from_pos.distance_squared_to(targets[i].global_position)
        if distance_squared < min_distance:
            min_distance = distance_squared
            min_distance_index = i

    return targets[min_distance_index]

# Return the farthest target from the given array.
static func get_farthest(from_node, targets):
    var max_distance = 0
    var max_distance_index = -1
    var from_pos = from_node.global_position

    for i in range(targets.size()):
        var distance_squared = from_pos.distance_squared_to(targets[i].global_position)
        if distance_squared > max_distance:
            max_distance = distance_squared
            max_distance_index = i

    return targets[max_distance_index]