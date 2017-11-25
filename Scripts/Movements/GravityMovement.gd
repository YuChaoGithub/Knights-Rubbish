var physics_body
var gravity

var dy = 0

func _init(physics_body, gravity):
    self.physics_body = physics_body
    self.gravity = gravity

func movement(curr_pos, delta):
    # If the body is collided with a platform vertically, set cancel the downward speed.
    if is_landed():
        dy = 0
    else:
        dy += gravity * delta

    return Vector2(curr_pos.x, curr_pos.y + dy * delta)

func is_landed():
    return physics_body.is_colliding() && physics_body.get_collision_normal().dot(Vector2(0, -1)) > 0.9