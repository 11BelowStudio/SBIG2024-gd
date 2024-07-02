extends "res://addons/maaacks_game_template/extras/scenes/WinScreen/WinScreen.gd"

func _ready() -> void:
	SceneLoader.load_scene(next_scene)
	InGameMenuController.close_menu()
