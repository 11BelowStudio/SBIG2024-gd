extends "res://addons/maaacks_game_template/extras/scenes/LoseScreen/LoseScreen.gd"

func _ready() -> void:
	SceneLoader.load_scene(main_menu_scene)
	InGameMenuController.close_menu()
