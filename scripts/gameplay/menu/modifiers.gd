class_name Modifiers
extends Control


signal speed_modified(new_user_speed_mod: float)
signal snap_modified(new_user_snap_mod: float)
signal regeneration_modified(new_user_regen_steps: int)
signal gravity_changed(user_gravity_changed: bool)

@onready var speed_label: Label = $Speed/Label
@onready var speed_slider: HSlider = $Speed/Slider

@onready var snap_label: Label = $Snapping/Label
@onready var snap_slider: HSlider = $Snapping/Slider

@onready var regeneration_label: Label = $Regeneration/Label
@onready var regeneration_slider: HSlider = $Regeneration/Slider

@onready var gravity_label: Label = $Gravity/Label
@onready var gravity_slider: HSlider = $Gravity/Slider


func _ready() -> void:
	speed_slider.value_changed.connect(_modify_speed)
	snap_slider.value_changed.connect(_modify_snap)
	regeneration_slider.value_changed.connect(_modify_regeneration)
	gravity_slider.value_changed.connect(_change_gravity)


func _modify_speed(new_value: float) -> void:
	if !bool(new_value):
		speed_label.text = "Speed mod: Normal"
	else:
		speed_label.text = ("Speed mod: %d%%" % int(new_value))
	speed_modified.emit((new_value + 100) / 100.0)


func _modify_snap(new_value: float) -> void:
	match int(new_value):
		0:
			snap_label.text = "Snapping: Disabled"
			snap_modified.emit(0)
		1:
			snap_label.text = "Snapping: Normal"
			snap_modified.emit(1)
		2:
			snap_label.text = "Snapping: Easy"
			snap_modified.emit(1.5)


func _modify_regeneration(new_value: float) -> void:
	match int(new_value):
		0:
			regeneration_label.text = "Regeneration: Disabled"
			regeneration_modified.emit(INF)
		1:
			regeneration_label.text = "Regeneration: Normal"
			regeneration_modified.emit(7)
		2:
			regeneration_label.text = "Regeneration: Easy"
			regeneration_modified.emit(5)


func _change_gravity(new_value: float) -> void:
	match int(new_value):
		0:
			gravity_label.text = "Gravity: Normal"
		1:
			gravity_label.text = "Gravity: Inversed"
	gravity_changed.emit(bool(new_value))
