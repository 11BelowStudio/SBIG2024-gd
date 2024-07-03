extends BaseScene

var _reached_room: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_apartment_hall_scene_player_in_room() -> void:
	if _reached_room:
		return
	_reached_room = true
	level_won.emit()
	pass # Replace with function body.
