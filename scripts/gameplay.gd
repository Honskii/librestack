extends Node3D


@export var camera: Camera3D
@export var base_margin: float = 1.2

const PLAYER = preload("uid://d07t74kikldjv")
const PLATFORM = preload("uid://cegiganni67tq")
const PLACED_BLOCK = preload("uid://dl7q5lgkp3vbx")
const FALLING_BLOCK = preload("uid://diqmhdvqwlhnu")
const COMBO_EFFECT = preload("uid://cvbr8m2085oeb")

@onready var falling_blocks: Node3D = $FallingBlocks
@onready var placed_blocks: Node3D= $PlacedBlocks
@onready var menu: Menu = $Menu
@onready var background: CanvasLayer = $WorldEnvironment/Background
@onready var gravity_effect: ColorRect = $Modifiers/GravityEffect
@onready var enabled_mods_label: Label = $Modifiers/EnabledModsLabel

const PLATFORM_SIZE := Vector3(8.0, 14.0, 8.0)
const PLATFORM_SQUARE := PLATFORM_SIZE.x * PLATFORM_SIZE.z
const START_SIZE := Vector3(PLATFORM_SIZE.x, 1, PLATFORM_SIZE.z)
const LAST_RESENT_SPAWNED_BLOCKS_LIMIT = 500
const FORGIVABLE_OFFSET: float = 0.375
const UNFORGIVABLE_OFFSET: float = 0.1
const CAMERA_POSITION := Vector3(-13.5, 17.5, -13.5)
const CAMERA_ROTATION := Vector3(deg_to_rad(-30), deg_to_rad(-135), 0)
const MIN_SCORE_BEFORE_CAMERA_MOVE: int = 7
const MIN_SCORE_BEFORE_CAMERA_CORRECTING: int = 15

const SPEED_MOD_RATIO = log(200)
const START_SPEED_MOD_RATIO = log(50) / log(200)

# Game statistics
var best_score: int = 0
var current_score: int = 0
var combo: int = 0
var max_combo: int = 0

# Game state
var is_playing := false
var is_dead := false
var is_restarting := false

# Nodes
var platform: StaticBody3D
var player: Player
var last_placed_block: Node3D

# Modificators and twists
var user_speed_mod: float = 1.0
var user_snapping_mod: float = 1.0
var user_regeneration_steps: int = 7
var enabled_mods: Dictionary = {}:
	set(value):
		enabled_mods = value


func _prepare_to_start() -> void:
	current_score = 0
	combo = 0
	max_combo = 0
	is_dead = false
	is_restarting = false
	create_platform()
	menu.show_main_menu()
	install_camera()


func _ready() -> void:
	best_score = SaveManager.current.best_score
	_prepare_to_start()
	menu.game_restart_required.connect(restart_game)
	menu.modifiers.gravity_changed.connect(change_gravity)
	menu.modifiers.speed_modified.connect(modify_speed)
	menu.modifiers.snap_modified.connect(modify_snapping)
	menu.modifiers.regeneration_modified.connect(modify_regen)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		if is_playing:
			if !is_dead:
				place_block()
		else:
			if !is_dead:
				create_player()
				menu.show_gameplay_hud()

		var falling_block_list = falling_blocks.get_children()
		while len(falling_block_list) >= LAST_RESENT_SPAWNED_BLOCKS_LIMIT:
			falling_block_list[0].queue_free()


func create_player() -> void:
	player = PLAYER.instantiate()
	player.size = START_SIZE
	self.add_child(player)
	player.set_speed_mod(user_speed_mod)
	is_playing = true


func create_platform() -> void:
	platform = PLATFORM.instantiate()
	platform.size = PLATFORM_SIZE
	platform.color = Color.DARK_GRAY
	self.add_child(platform)
	platform.install(Vector3(
		0, -PLATFORM_SIZE.y / 2, 0
	))
	last_placed_block = platform


func place_block() -> void:
	var result_axis_size: float
	var result_axis_pos: float
	var new_falling_block
	var axis_index: int = player.get_axis_index()

	var player_axis_pos: float = player.position[axis_index]
	var player_axis_size: float = player.size[axis_index]
	var last_placed_axis_pos: float = last_placed_block.position[axis_index]
	var last_placed_axis_size: float = last_placed_block.size[axis_index]

	if (
		abs(player_axis_pos - last_placed_axis_pos) <=
		FORGIVABLE_OFFSET * user_snapping_mod
	):
		result_axis_size = last_placed_axis_size
		result_axis_pos = last_placed_axis_pos

		combo += 1
		if max_combo < combo:
			max_combo = combo
		InputUtils.slight_vibrate()

		var combo_effect = COMBO_EFFECT.instantiate()
		combo_effect.size = Vector2(
			player.size[0],
			player.size[2]
		)
		self.add_child(combo_effect)
		combo_effect.position = Vector3(
			last_placed_block.position.x,
			player.position.y - 0.5,
			last_placed_block.position.z
		)
		combo_effect.play_animation()
	else:
		combo = 0
		result_axis_size = player_axis_size - abs(
			player_axis_pos - last_placed_axis_pos
		)
		result_axis_pos = (
			max(player_axis_pos, last_placed_axis_pos) -
			(player_axis_size - result_axis_size) / 2
		)

	if result_axis_size <= UNFORGIVABLE_OFFSET:
		is_dead = true

		# Falling slice
		new_falling_block = FALLING_BLOCK.instantiate()
		new_falling_block.size = player.size
		new_falling_block.color = player.color
		new_falling_block.position = player.position
		falling_blocks.add_child(new_falling_block)

		player.queue_free()
		is_playing = false

		# Menu
		menu.show_game_over_menu()
		menu.set_best_score(best_score)
		if current_score > best_score:
			best_score = current_score
			menu.new_best_score()
			SaveManager.current.best_score = best_score
			SaveManager.save_game()

		return

	# New player properties
	player.size[axis_index] = result_axis_size
	player.position[axis_index] = result_axis_pos

	# Place block
	var new_placed_block = PLACED_BLOCK.instantiate()
	new_placed_block.size = player.size
	new_placed_block.position = player.position
	new_placed_block.position[axis_index] = result_axis_pos
	new_placed_block.color = player.color
	placed_blocks.add_child(new_placed_block)

	var combo_speed_mod: float = 0.0
	if combo >= user_regeneration_steps and new_placed_block.size != START_SIZE:
		var target_size: Vector3 = new_placed_block.size
		var target_position: Vector3 = new_placed_block.position
		var target_axis_size: float

		var left_axis_size: float = (
			PLATFORM_SIZE[axis_index] - new_placed_block.size[axis_index])

		if left_axis_size > 0:

			combo_speed_mod = log(combo - user_regeneration_steps + 3) / 3.0

			var size_increase = left_axis_size / ceil(left_axis_size / 1.5)
			target_axis_size = new_placed_block.size[axis_index] + size_increase
			target_size[axis_index] = target_axis_size
			if new_placed_block.position[axis_index] >= 0:
				target_position[axis_index] -= size_increase / 2
			else:
				target_position[axis_index] += size_increase / 2

			player.size = target_size
			player.position = target_position
			new_placed_block.enlarge(
				target_size,
				0.5
			)

			TweenUtils.smooth_move(new_placed_block, target_position, 0.5)

	# Falling slice
	if result_axis_pos != last_placed_axis_pos:
		new_falling_block = FALLING_BLOCK.instantiate()
		new_falling_block.position = player.position
		if player_axis_pos > last_placed_axis_pos:
			new_falling_block.position[axis_index] = (
				(player_axis_pos - last_placed_axis_pos) / 2 +
				last_placed_axis_pos + last_placed_axis_size / 2
			)
		else:
			new_falling_block.position[axis_index] = (
				(last_placed_axis_pos - player_axis_pos) / 2 +
				player_axis_pos - player_axis_size / 2
			)
		new_falling_block.size = player.size
		new_falling_block.size[axis_index] = (
			abs(player_axis_pos - last_placed_axis_pos)
		)
		new_falling_block.color = player.color
		falling_blocks.add_child(new_falling_block)

	current_score += 1
	menu.set_score(current_score)

	last_placed_block = new_placed_block

	ColorUtils.new_color()
	player.set_speed_mod((
		(log(current_score + combo + 50) / SPEED_MOD_RATIO)
		/ START_SPEED_MOD_RATIO +
		sin((Time.get_unix_time_from_system()) * 100) * 0.02 +
		abs(sin(current_score / 3.0) * 0.1) +
		current_score / 1075.0 +
		combo_speed_mod
	) * user_speed_mod)

	player.new_round()

	if current_score > MIN_SCORE_BEFORE_CAMERA_MOVE:
		var new_camera_position: Vector3
		if current_score > MIN_SCORE_BEFORE_CAMERA_CORRECTING:
			new_camera_position = Vector3(
				(
					camera.position.x * 0.9 + 
					(CAMERA_POSITION.x + last_placed_block.position.x) * 0.1
				),
				CAMERA_POSITION.y + current_score - MIN_SCORE_BEFORE_CAMERA_MOVE,
				(
					camera.position.z * 0.9 +
					(CAMERA_POSITION.z + last_placed_block.position.z) * 0.1
				)
			)
		else:
			new_camera_position = Vector3(
				CAMERA_POSITION.x,
				CAMERA_POSITION.y + current_score - MIN_SCORE_BEFORE_CAMERA_MOVE,
				CAMERA_POSITION.z,
			)
		
		TweenUtils.smooth_move_split(
			camera,
			new_camera_position,
			0.25,
			0.25
		)


func restart_game() -> void:
	menu.hide_restart_button()
	update_camera_framing()
	var timer
	timer = get_tree().create_timer(calculate_time_to_descent() / 3)
	while timer.time_left > 0:
		await get_tree().process_frame
	current_score = 0
	if is_restarting:
		return
	is_restarting = true
	_all_placed_blocks_to_falling()
	timer = get_tree().create_timer(5.0)

	while timer.time_left > 0:
		if len(falling_blocks.get_children()) == 0:
			_prepare_to_start()
			return
		await get_tree().process_frame

	free_all_falling_blocks()
	_prepare_to_start()

	InputUtils.vibrate(200)


func free_all_falling_blocks() -> void:
	for fb in falling_blocks.get_children():
		fb.queue_free()


func _all_placed_blocks_to_falling() -> void:
	for fb in falling_blocks.get_children():
		fb.gravity_scale = 12.0
		fb.apply_impulse(_calculate_random_impulse_strength())

	for pb in placed_blocks.get_children():
		var new_falling_block = FALLING_BLOCK.instantiate()
		new_falling_block.position = pb.position
		new_falling_block.size = pb.size
		new_falling_block.color = pb.color
		falling_blocks.add_child(new_falling_block)
		new_falling_block.gravity_scale = 12.0
		new_falling_block.apply_impulse(_calculate_random_impulse_strength())
		pb.queue_free()

	platform.drop_and_remove()


func _calculate_random_impulse_strength() -> Vector3:
	var random_dir = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(0.2, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()
	var random_ratio = randf_range(10.0, 15.0)
	return random_dir * random_ratio


func install_camera() -> void:
	camera.position = CAMERA_POSITION
	camera.rotation = CAMERA_ROTATION


func update_camera_framing() -> void:
	if not camera:
		return

	TweenUtils.smooth_move(
		camera,
		CAMERA_POSITION,
		calculate_time_to_descent()
	)


func calculate_time_to_descent() -> float:
	return current_score * 0.015


# ===== MODIFIERS ===== #

func change_gravity(user_gravity_changed: bool) -> void:
	gravity_effect.visible = user_gravity_changed

func modify_speed(new_user_speed_mod: float) -> void:
	self.user_speed_mod = new_user_speed_mod
	if new_user_speed_mod != 1.0:
		enabled_mods["Speed"] = "x %.2f" % new_user_speed_mod
	else:
		enabled_mods.erase("Speed")
	_update_enabled_mods_label()

func modify_snapping(new_user_snapping_mod: float) -> void:
	self.user_snapping_mod = new_user_snapping_mod
	if new_user_snapping_mod == 1.5:
		enabled_mods["Snapping"] = "easy"
	elif new_user_snapping_mod == 0:
		enabled_mods["Snapping"] = "disabled"
	else:
		enabled_mods.erase("Snapping")
	_update_enabled_mods_label()		

func modify_regen(new_user_regen_steps: int) -> void:
	self.user_regeneration_steps = new_user_regen_steps
	if new_user_regen_steps == 5:
		enabled_mods["Regen"] = "easy"
	elif new_user_regen_steps == INF:
		enabled_mods["Regen"] = "disabled"
	else:
		enabled_mods.erase("Regen")
	_update_enabled_mods_label()


func _update_enabled_mods_label():
	var text_lines = []
	
	for key in enabled_mods:
		text_lines.append(str(key) + ": " + str(enabled_mods[key]))
	
	enabled_mods_label.text = "\n".join(text_lines)
