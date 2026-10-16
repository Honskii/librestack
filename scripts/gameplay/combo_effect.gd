extends Node3D


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var size: Vector2
var expand_size: float = 1.0
var animation_duration: float = 0.750


func play_animation() -> void:
	TweenUtils.smooth_mesh_size(
		mesh_instance, 
		Vector3(size[0] + expand_size, 0, size[1] + expand_size),
		animation_duration
	)
	await _fade_out_mesh().finished
	queue_free()


func _fade_out_mesh() -> Tween:
	var mat = mesh_instance.get_active_material(0)
	if not mat:
		return null

	var material = mat.duplicate() as BaseMaterial3D
	mesh_instance.set_surface_override_material(0, material)

	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(material, "albedo_color:a", 0.0, animation_duration)

	tween.tween_callback(func(): mesh_instance.visible = false)
	
	return tween


func _set_properties() -> void:
	mesh_instance.mesh.size = Vector3(size[0], 0, size[1])


func _ready() -> void:
	_set_properties()
