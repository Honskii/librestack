extends Node


func slight_vibrate() -> void:
	if SaveManager.current.player_settings.get("vibrate", true):
		Input.vibrate_handheld(40, 0.5)
		Input.start_joy_vibration(0, 0.3, 0.0, 0.2)

func vibrate(duration: int = 200) -> void:
	if SaveManager.current.player_settings.get("vibrate", true):
		Input.vibrate_handheld(duration, 0.5)
		Input.start_joy_vibration(0, 0.3, 0.0, duration / 1000.0)
