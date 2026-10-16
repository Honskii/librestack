extends RigidBody3D


const GRAVITY: float = 20.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

const lower_limit = -40

var size: Vector3 = Vector3(0.0, 0.0, 0.0)
var color: Color = Color.TRANSPARENT


func _set_properties() -> void:
	# Size
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.size = size
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	mesh_instance.mesh.size = size

	# Material Color
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material


func _ready() -> void:
	_set_properties()


func _physics_process(_delta: float) -> void:
	if global_position.y < lower_limit:
		queue_free()
