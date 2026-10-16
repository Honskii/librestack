extends Node

var SAVE_PATH: String = ""
var current: GameSave

func _ready():
	var appdata = OS.get_environment("APPDATA")

	if appdata != "":
		SAVE_PATH = appdata.path_join("FuchsineLab/LibreStack/save.tres")
	else:
		SAVE_PATH = "user://FuchsineLab/LibreStack/save.tres"
		
	load_game()

func load_game():
	var dir_path = SAVE_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)

	if FileAccess.file_exists(SAVE_PATH):
		current = ResourceLoader.load(SAVE_PATH) as GameSave
		if current:
			return

	current = GameSave.new()

func save_game():
	var dir_path = SAVE_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	ResourceSaver.save(current, SAVE_PATH)
