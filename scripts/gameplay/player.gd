class_name Player
extends Node3D

enum Axis { X, Z }

@export var SPEED: int = 12

const POS_LIMIT: float = 10
const COLOR_MIX_STEPS: int = 5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var axis: Axis
var speed_mod: float = 1.0
var direction: int = -1
var move: Callable

var size: Vector3 = Vector3(1.0, 1.0, 1.0)
var color: Color = Color.TRANSPARENT


func get_square() -> float:
	return size.x * size.z

func get_axis_index() -> int:
	if axis == Axis.X:
		return 2
	return 0

func increase_speed(value: float) -> void:
	speed_mod += value

func set_speed_mod(value: float) -> void:
	speed_mod = value


func new_round() -> void:
	if axis == Axis.X:
		move = _move_x
		position.y += 1
		position.x = POS_LIMIT
		axis = Axis.Z
	else:
		move = _move_z
		position.y += 1
		position.z = POS_LIMIT
		axis = Axis.X

	_set_color()
	_set_properties()


func _set_color():
	color = ColorUtils.get_current_color()


func _set_properties() -> void:
	mesh_instance.mesh.size = size
	mesh_instance.material_override.albedo_color = color


func _calculate_abs_delta_pos(delta: float) -> float:
	return direction * SPEED * delta * speed_mod


func _move_x(delta: float) -> Vector3:
	if position.x >= POS_LIMIT:
		direction = -1
	elif position.x <= -POS_LIMIT:
		direction = 1
	var delta_pos = _calculate_abs_delta_pos(delta)
	return Vector3(delta_pos, 0, 0)

func _move_z(delta: float) -> Vector3:
	if position.z >= POS_LIMIT:
		direction = -1
	elif position.z <= -POS_LIMIT:
		direction = 1
	var delta_pos = _calculate_abs_delta_pos(delta)
	return Vector3(0, 0, delta_pos)


func _ready() -> void:
	mesh_instance.material_override = StandardMaterial3D.new()
	position = Vector3(0, -0.5, 0)
	_set_color()
	ColorUtils.new_color_set.connect(_set_color)
	axis = Axis.Z
	new_round()


func _physics_process(delta: float) -> void:
	position += move.call(delta)
