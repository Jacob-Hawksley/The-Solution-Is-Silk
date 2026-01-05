extends Area3D

var speed = 50.0 # Adjust bullet speed
@onready var lifespan = 0
func _physics_process(delta):
	# Move forward in the direction the bullet is facing
	position -= transform.basis.z * speed * delta
	lifespan += delta
	if lifespan >= 5:
		queue_free()
