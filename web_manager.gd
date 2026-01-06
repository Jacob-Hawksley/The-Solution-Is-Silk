extends Node3D

@export_group("Settings")
@export var segment_scene: PackedScene = preload("res://web.tscn")# Assign your RigidBody3D segment scene here
@export var segment_length: float = 0.42 # Length of one link (in meters)
@export var rope_count: int = 10 # How many links

@export_group("Attachments")
@onready var attach_start  # The ceiling/anchor (StaticBody3D)
@onready var attach_end   # The object hanging (RigidBody3D)

func _process(delta: float) -> void:
	if Main.connectionpoint == 3:
		spawn_rope()
		Main.connectionpoint = 1

func spawn_rope():
	attach_start = Main.connectfrom
	attach_end = Main.connectto
	if not attach_start or not segment_scene:
		push_error("Rope Generator: Missing start body or segment scene.")
		return
	rope_count = 1 + floor((Main.connectfrom.global_position.distance_to(Main.connectto.global_position))/segment_length)
	var prev_body = attach_start
	# Start positioning slightly below the anchor
	var current_pos = attach_start.global_position
	
	for i in range(rope_count):
		# 1. Instantiate the segment
		var new_seg = segment_scene.instantiate()
		add_child(new_seg)
		
		# 2. Position it relative to the previous body
		# In 3D, "Down" is usually Negative Y. 
		# We calculate the position for the NEW segment.
		var offset = Vector3(0, -segment_length, 0)
		new_seg.global_position = current_pos + offset
		
		# 3. Create the Joint
		var joint = PinJoint3D.new()
		add_child(joint)
		
		# 4. Position the joint
		# The joint should be physically located between the two bodies
		joint.global_position = current_pos + (offset / 2.0)
		
		# 5. Connect the bodies
		joint.node_a = prev_body.get_path()
		joint.node_b = new_seg.get_path()
		
		# 6. Update variables for the next loop
		prev_body = new_seg
		current_pos = new_seg.global_position

	# 7. Attach the final object (if selected)
	if attach_end:
		var end_joint = PinJoint3D.new()
		add_child(end_joint)
		
		# Place joint between last segment and the end object
		var offset = Vector3(0, -segment_length, 0)
		end_joint.global_position = current_pos + (offset / 2.0)
		
		# If the end object is already far away, you might want to snap it 
		# to the rope end here:
		# attach_end.global_position = current_pos + offset
		
		end_joint.node_a = prev_body.get_path()
		end_joint.node_b = attach_end.get_path()
