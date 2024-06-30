class_name Heartbeater
extends AudioStreamPlayer


@export var _min_delay_delta: float = 0.3
@export var _max_delay_delta: float = 2

@export var _delta_lerp_amount: float = 0.75

@export var intensity_target: float = 0:
	set(value):
		if value > 1:
			value = 1
		if value < 0:
			value = 0
		intensity_target = value



@export var intensity: float = 0:
	set(value):
		if value < 0:
			value = 0
		elif value > 1:
			value = 1
		
		intensity = value
		intensity_target = value
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
	
	if intensity != intensity_target:
		var delta_lerp = _delta_lerp_amount
		if intensity_target < intensity:
			delta_lerp = 1 - delta_lerp
		intensity = lerpf(intensity, intensity_target, delta_lerp * delta)
	
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
