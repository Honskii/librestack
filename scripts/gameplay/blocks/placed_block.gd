extends StaticBody3D


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var size: Vector3 = Vector3(0.0, 0.0, 0.0)
var color: Color = Color.TRANSPARENT


func enlarge(target_size: Vector3, duration: float) -> void:
	TweenUtils.smooth_mesh_size(
		mesh_instance,
		target_size,
		duration
	)


func _set_properties() -> void:
	# Size
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.size = size
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	mesh_instance.mesh.size = size

	# Material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material


func _ready() -> void:
	_set_properties()
