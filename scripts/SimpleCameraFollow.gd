extends Camera3D


@export var target: Node3D
@export var offset := Vector3(6.0, 7.0, 8.0)
@export var follow_speed := 6.0


func _physics_process(delta: float) -> void:
	if target == null:
		return

	global_position = global_position.lerp(target.global_position + offset, follow_speed * delta)
	look_at(target.global_position + Vector3(0, 1.0, 0), Vector3.UP)
