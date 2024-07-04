extends BaseScene

var _reached_room: bool = false

@onready var apartment: ApartmentHallScene = $ApartmentHallScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apartment.fpui.vignette_intensity(character.real_fov_intensity)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	apartment.fpui.vignette_intensity(character.real_fov_intensity)
	pass

func _on_apartment_hall_scene_player_room_midpoint() -> void:
	if _reached_room:
		return
	_reached_room = true
	level_won.emit()
	pass # Replace with function body.
