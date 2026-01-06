extends Area3D

var connection
var speed = 50.0 # Adjust bullet speed
var decaying = true
@onready var lifespan = 0
func _physics_process(delta):
	position -= transform.basis.z * speed * delta
	if decaying:
		lifespan += delta
	if lifespan >= 5:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	speed = 0
	decaying = false
	if Main.connectionpoint == 1:
		if body is GridMap:
			detach_tile(body)
		elif body is StaticBody3D or body is RigidBody3D:
			connection = body
		Main.connectfrom = connection
		Main.connectionpoint = 2
	elif Main.connectionpoint == 2:
		if body is GridMap:
			detach_tile(body)
		elif body is StaticBody3D or body is RigidBody3D:
			connection = body
		Main.connectto = connection
		Main.connectionpoint = 3

func detach_tile(body):
	var tile_id = body.get_cell_item(body.local_to_map(body.to_local(global_position)))
	if tile_id == GridMap.INVALID_CELL_ITEM:
		return
		
	# 2. Delete the tile from the GridMap (turn it to air)
	body.set_cell_item(body.local_to_map(body.to_local(global_position)), GridMap.INVALID_CELL_ITEM)
	
	# 3. Spawn a real RigidBody3D scene in its place
	var new_rubble = preload("res://gridmap.tscn").instantiate()
	add_child(new_rubble)
	
	# 4. Move it to the GridMap cell's position
	new_rubble.global_position = body.map_to_local(body.local_to_map(body.to_local(global_position)))
	connection = new_rubble.get_child(0).get_child(0)
