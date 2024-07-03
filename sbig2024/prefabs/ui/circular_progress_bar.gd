
class_name CircularProgressBar
extends TextureProgressBar

@export var visible_transparency: float = 1

@export var _length_fade_out: float = 2

var _last_known_value: float = 0

var fade_out_timer = _length_fade_out

var _fading_out: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = 0
	fade_out_timer = 0
	_fading_out = false
	pass # Replace with function body.

func _value_changed(new_value: float) -> void:
	if new_value > _last_known_value:
		refresh_show()
	
func force_hide() -> void:
	fade_out_timer = 0
	self_modulate.a = 0
	_fading_out = false
	
func refresh_show() -> void:
	fade_out_timer = _length_fade_out
	self_modulate.a = visible_transparency
	_fading_out = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_last_known_value = value
	if _fading_out:
		if fade_out_timer <= 0:
			_fading_out = false
			self_modulate.a = 0
		else:
			var fade_left_01 = fade_out_timer/_length_fade_out
			self_modulate.a = visible_transparency * fade_left_01
			fade_out_timer -= delta
	pass
