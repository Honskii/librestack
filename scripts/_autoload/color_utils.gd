extends Node


signal new_color_set

const COLOR_MIX_STEPS: int = 8

var possible_block_colors = [
	Color("#E4717A"), Color("#FF9BAA"), Color("#FF7514"),
	Color("#EFA94A"), Color("#EFCDB8"), Color("#F0E68C"),
	Color("#FF8C69"), Color("#FFBD88"), Color("#FFB28B"),
	Color("#FFBCAD"), Color("#FAD6A5"), Color("#FDDB6D"),
	Color("#FCE883"), Color("#FCD975"), Color("#FCDD76"),
	Color("#E7C697"), Color("#F0DC82"), Color("#FFC1CC"), 
	Color("#A18594"), Color("#77DD77"), Color("#FFD1DC"),
	Color("#7FB5B5"), Color("#AFDAFC"), Color("#E6E6FA"),
	Color("#99FF99"), Color("#F5F5DC"), Color("#EEE6A3"),
	Color("#FFF0F5"), Color("#E6D690"), Color("#EAE0C8"),
	Color("#B39F7A"), Color("#3EB489"), Color("#ACE5EE"),
	Color("#CCCCFF"), Color("#AFEEEE"), Color("#A2A2D0"),
	Color("#F9F8BB"), Color("#D8BFD8"), Color("#9FE2BF"),
	Color("#9ACEEB"), Color("#EDD19C"), Color("#71BC78"),
	Color("#7FC7FF"), Color("#DCD0FF"), Color("#ACE1AF"),
	Color("#BADBAD"),
]
var possible_colors_count: int = len(possible_block_colors)
var current_step: int = 0

var current_color_index: int:
	get:
		@warning_ignore("integer_division")
		return current_step / COLOR_MIX_STEPS


func new_color() -> void:
	if current_color_index >= possible_colors_count:
		current_step = 0
	current_step += 1
	new_color_set.emit()


func get_current_color(offset: int = 0) -> Color:
	var color: Color = _mix_colors_by_current_step(
		_get_color_with_rotation(current_color_index + offset),
		_get_color_with_rotation(current_color_index + offset + 1)
	)
	return color


func _get_color_with_rotation(index: int) -> Color:
	index %= possible_colors_count
	return possible_block_colors[index]


func _mix_colors_by_current_step(color1: Color, color2: Color) -> Color:
	var ratio := float(current_step % COLOR_MIX_STEPS) / float(COLOR_MIX_STEPS)
	return color1.lerp(color2, ratio)


func _ready() -> void:
	possible_block_colors.shuffle()
