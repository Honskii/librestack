extends Node


func smooth_move(
	node: Node3D,
	target_pos: Vector3,
	duration: float = 0.3
) -> Tween:
	var tween = node.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", target_pos, duration)
	return tween

func smooth_move_2d(
	node: CanvasItem,
	target_pos: Vector2,
	duration: float = 0.3
) -> Tween:
	var tween = node.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", target_pos, duration)
	return tween

func smooth_move_split(
	node: Node3D,
	target_pos: Vector3,
	duration_y: float = 0.2,
	duration_xz: float = 0.2
) -> Tween:
	var tween = node.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(node, "position:x", target_pos.x, duration_xz)
	tween.tween_property(node, "position:y", target_pos.y, duration_y)
	tween.tween_property(node, "position:z", target_pos.z, duration_xz)

	return tween


func smooth_shader_color(
	node: Node,
	material: ShaderMaterial,
	colors: Dictionary,
	duration: float = 0.2
) -> Tween:
	var tween = node.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	for param_name in colors.keys():
		var target_color = colors[param_name]
		
		var property_path = param_name
		if not property_path.begins_with("shader_parameter/"):
			property_path = "shader_parameter/" + param_name
			
		tween.tween_property(material, property_path, target_color, duration)
		
	return tween


func smooth_scale(
	node: Node3D,
	target_scale: Vector3,
	duration: float = 0.2
) -> Tween:
	var tween = node.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", target_scale, duration)
	return tween


func smooth_mesh_size(
	mesh_instance: MeshInstance3D,
	target_size: Vector3,
	duration: float
) -> Tween:
	if not mesh_instance.mesh:
		return null
	
	var mesh_resource = mesh_instance.mesh.duplicate()
	mesh_instance.mesh = mesh_resource

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(mesh_resource, "size", target_size, duration)
	return tween


func smooth_camera_size(
	camera: Camera3D,
	new_size: float,
	duration: float = 2.0
) -> Tween:
	var tween = camera.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "size", new_size, duration)
	return tween
