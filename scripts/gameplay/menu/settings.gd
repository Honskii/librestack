extends Control


@onready var volume_slider: HSlider = $Volume/Slider
@onready var volume_label: Label = $Volume/Label

@onready var vibration_button: Button = $Vibration/Button


func _ready() -> void:
	var volume = SaveManager.current.player_settings.get("volume", 100)
	volume_slider.value = volume
	change_volume(volume)

	var vibration_mode = (
		SaveManager.current.player_settings.get("vibrate", true))
	vibration_button.button_pressed = vibration_mode
	toggle_vibration(vibration_mode)

	volume_slider.value_changed.connect(change_volume)
	vibration_button.toggled.connect(toggle_vibration)


func change_volume(new_value: float) -> void:
	# TODO: РЕАЛИЗОВАТЬ ИЗМЕНЕНИЕ ЗВУКА
	print("new_volume: %.0f%%" % new_value)
	volume_label.text = "Volume: %d%%" % int(new_value)
	SaveManager.current.player_settings["volume"] = new_value


func toggle_vibration(toggle_on: bool) -> void:
	if toggle_on:
		vibration_button.text = "ᛊ Enabled ᛊ"
		SaveManager.current.player_settings["vibrate"] = true
	else:
		vibration_button.text = "Disabled"
		SaveManager.current.player_settings["vibrate"] = false
