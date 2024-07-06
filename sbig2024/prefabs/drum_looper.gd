class_name DrumLooper
extends AudioStreamPlayer

@onready var _loop2 = $Loop2

@export_range(0, 1) var _current_volume: float = 0

@export_range(0, 1) var max_target: float = 1

@export_range(0, 1) var _lerp_delta: float = 0.5

enum DrumStates { OFF, LOOP0, LOOP1, LOOP2 }

@export var drum_state: DrumStates = DrumStates.OFF:
	set(value):
		drum_state = value
		match value:
			DrumStates.OFF:
				_current_volume = 0
				volume_db = linear_to_db(0)
				if _loop2:
					_loop2.volume_db = linear_to_db(0)
			DrumStates.LOOP0:
				volume_db = linear_to_db(_current_volume)
				if _loop2:
					_loop2.volume_db = linear_to_db(0)
			DrumStates.LOOP1:
				volume_db = linear_to_db(_current_volume)
				if _loop2:
					_loop2.volume_db = linear_to_db(0)
			DrumStates.LOOP2:
				volume_db = linear_to_db(_current_volume)
				if _loop2:
					_loop2.volume_db = linear_to_db(_current_volume)


func _target() -> float:
	match drum_state:
		DrumStates.OFF:
			return 0
		DrumStates.LOOP0:
			return 0
		DrumStates.LOOP1:
			return max_target
		DrumStates.LOOP2:
			return max_target
		_:
			return max_target


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drum_state = drum_state
	play()
	_loop2.play()
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if drum_state == DrumStates.OFF:
		return
	
	var target: float = _target()
	if !is_equal_approx(target, _current_volume):
		_current_volume = lerpf(_current_volume, target, delta * _lerp_delta)
		volume_db = linear_to_db(_current_volume)
		if drum_state == DrumStates.LOOP2:
			_loop2.volume_db = linear_to_db(_current_volume)
	
	pass


