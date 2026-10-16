class_name Menu
extends CanvasLayer


signal game_restart_required

@onready var logo: Control = $Logo
@onready var start_menu: Control = $StartMenu
@onready var restart_menu: Control = $RestartMenu
@onready var score_label: Label = $ScoreLabel
@onready var best_score_label: Label = $BestScoreLabel
@onready var restart_menu_button: Button = $RestartMenu/Button
@onready var mods_button: Button = $Navigation/ModsButton
@onready var home_button: Button = $Navigation/HomeButton
@onready var settings_button: Button = $Navigation/SettingsButton

@onready var navigation: Control = $Navigation
@onready var modifiers: Modifiers = $Modifiers
@onready var settings: Control = $Settings


var block_other_pages: bool = false
var navigation_pos: Vector2 


func _ready() -> void:
	restart_menu_button.pressed.connect(game_restart_required.emit)
	mods_button.pressed.connect(_show_modifiers)
	settings_button.pressed.connect(_show_settings)
	home_button.pressed.connect(_press_home)
	navigation_pos = navigation.position


func _switch_navigation_visability(show_navigation: bool) -> void:
	if show_navigation:
		mods_button.mouse_filter = Control.MOUSE_FILTER_STOP
		home_button.mouse_filter = Control.MOUSE_FILTER_STOP
		settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
		block_other_pages = false
		TweenUtils.smooth_move_2d(navigation, navigation_pos, 0.3)
	else:
		_press_home()
		mods_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		home_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		settings_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		block_other_pages = true
		TweenUtils.smooth_move_2d(navigation, navigation_pos * 1.2, 0.3)


func _show_modifiers() -> void:
	if block_other_pages:
		return

	if modifiers.visible:
		modifiers.visible = false
	else:
		_press_home()
		modifiers.visible = true
		

func _show_settings() -> void:
	if block_other_pages:
		return

	if settings.visible:
		settings.visible = false
	else:
		_press_home()
		settings.visible = true

func _press_home() -> void:
	SaveManager.save_game()
	modifiers.visible = false
	settings.visible = false


func set_score(score: int) -> void:
	score_label.text = str(score)

func set_best_score(score: int) -> void:
	best_score_label.text = "Best: %d" % score

func new_best_score() -> void:
	best_score_label.text = "New record!"


func show_main_menu() -> void:
	logo.visible = true
	start_menu.visible = true

	restart_menu.visible = false
	score_label.visible = false
	best_score_label.visible = false

	_switch_navigation_visability(true)

func show_gameplay_hud() -> void:
	reset_score_counter()
	score_label.visible = true

	logo.visible = false
	start_menu.visible = false
	restart_menu.visible = false
	best_score_label.visible = false

	_switch_navigation_visability(false)

func show_game_over_menu() -> void:
	score_label.visible = true
	best_score_label.visible = true

	logo.visible = false
	start_menu.visible = false

	restart_menu_button.disabled = true
	await get_tree().create_timer(1).timeout
	restart_menu.visible = true
	restart_menu_button.disabled = false

func hide_restart_button() -> void:
	restart_menu.visible = false

func reset_score_counter() -> void:
	score_label.text = ""
