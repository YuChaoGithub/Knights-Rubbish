var dx
var dy = 0
var gravity
var physics_body

func _init(dx, gravity, physics_body):
    self.dx = dx
    self.gravity = gravity
    self.physics_body = physics_body

func movement(curr_pos, delta):
    # If the body is collided with a platform vertically, set cancel the downward speed.
    if physics_body.is_colliding() && physics_body.get_collision_normal().dot(Vector2(0, -1)) > 0.9:
        dy = 0
    else:
        dy += gravity * delta
        
    return Vector2(curr_pos.x + dx * delta, curr_pos.y + dy * delta)