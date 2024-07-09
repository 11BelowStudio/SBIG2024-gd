extends "res://addons/maaacks_game_template/extras/scenes/PauseMenu/PauseMenu.gd"


func _on_resume_button_pressed():
	super._on_resume_button_pressed()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if popup_open != null:
			close_popup()
		elif %SubMenuContainer.visible:
			close_options_menu()
		else:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			InGameMenuController.close_menu()

