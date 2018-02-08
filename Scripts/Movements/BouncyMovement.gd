var physics_body
var gravity
var bounciness

var velocity

func _init(physics_body, velocity, gravity, bounciness):
    self.physics_body = physics_body
    self.velocity = velocity
    self.gravity = gravity
    self.bounciness = bounciness

func movement(delta):
    if physics_body.is_colliding():
        var normal = physics_body.get_collision_normal()
        velocity = normal.reflect(velocity) * bounciness
    else:
        velocity.y += gravity * delta

    return velocity * delta