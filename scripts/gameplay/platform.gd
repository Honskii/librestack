extends StaticBody3D


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


var size: Vector3
var color: Color


func _set_fog_color() -> void:
	var material = mesh_instance.get_active_material(0) as ShaderMaterial
	if not material:
		return

	var fog_color = ColorUtils.get_current_color(17).lerp(
		Color("#ffffff"), 0.4)
	material.set_shader_parameter("fog_color", fog_color)
	TweenUtils.smooth_shader_color(
		mesh_instance,
		material,
		{
			"fog_color": ColorUtils.get_current_color(17).lerp(
		Color("#ffffff"), 0.4)
		},
		5
	)


func _set_properties() -> void:
	# Size
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.size = size
	mesh_instance.mesh = mesh_instance.mesh.duplicate()
	mesh_instance.mesh.size = size

	# Material Color
	var material = mesh_instance.get_active_material(0) as ShaderMaterial
	var top_color = Color(0.3, 0.3, 0.3, 1.0).lerp(
		ColorUtils.get_current_color(), 0.5
	)
	var bottom_color = Color(0.3, 0.3, 0.3, 1.0).lerp(
		ColorUtils.get_current_color(), 0.3
	)
	material.set_shader_parameter("object_top_color", top_color)
	material.set_shader_parameter("object_bottom_color", bottom_color)
	mesh_instance.material_override = material

	# Fog
	_set_fog_color()


func _ready() -> void:
	_set_properties()
	ColorUtils.new_color_set.connect(_set_fog_color)


func install(new_position: Vector3) -> void:
	self.position = Vector3(0, -20, 0)
	await TweenUtils.smooth_move(self, new_position, 0.5).finished


func drop_and_remove() -> void:
	var new_position = Vector3(
		position.x,
		position.y - 50,
		position.z
	)

	await TweenUtils.smooth_move(self, new_position, 0.5).finished

	queue_free()
