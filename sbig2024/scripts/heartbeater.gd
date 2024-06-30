class_name Heartbeater
extends AudioStreamPlayer


@export var _min_delay_delta: float = 0.3
@export var _max_delay_delta: float = 2

@export var intensity: float = 0:
	set(value):
		if value < 0:
			value = 0
		elif value > 1:
			value = 1
		
		intensity = value
		var delay_range : float = _max_delay_delta - _min_delay_delta
		_current_delay = _max_delay_delta - (delay_range * value)
		

var _current_delay: float = _max_delay_delta

const second_beat_delay: float = 0.2

@onready var _timer0: float = _current_delay

@onready var _timer1: float = _current_delay + second_beat_delay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	_timer0 -= delta
	if _timer0 <= 0:
		play()
		_timer1 = second_beat_delay
		_timer0 += _current_delay
	if _timer1 > 0:
		_timer1 -= delta
		if _timer1 <= 0:
			play()
	
	pass
