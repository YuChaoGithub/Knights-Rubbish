var physics_body
var gravity

var dy = 0.0
var is_landed = false

func _init(physics_body, gravity):
    self.physics_body = physics_body
    self.gravity = gravity

func move(delta):
    var collision = physics_body.move_and_collide(Vector2(0.0, dy * delta))
    is_landed = collision != null && collision.normal.dot(Vector2(0.0, -1.0)) > 0.9

    if is_landed:
        dy = 0.0
    else:
        dy += gravity * delta