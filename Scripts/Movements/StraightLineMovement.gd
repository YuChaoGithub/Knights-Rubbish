# Displacement per second.
var dx
var dy

# Constructor.
func _init(dx, dy):
    self.dx = dx
    self.dy = dy

func movement(delta):
    return Vector2(dx * delta, dy * delta)

func set_velocity(dx, dy):
    self.dx = dx
    self.dy = dy