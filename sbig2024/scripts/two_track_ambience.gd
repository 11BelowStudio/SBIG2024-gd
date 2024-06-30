
class_name TwoTrackAmbience
extends Node
## class that controls an ambience thing that could fade between two tracks

@export var audio0: AudioStream
@export var audio1: AudioStream

## The lerp amount between the current audio weight and the target.
@export var _delta_lerp_amount: float = 0.5

enum TrackBias {NEITHER, AUDIO0, AUDIO1}

## use this to decide if we want a bias towards a certain track
@export var _track_bias: TrackBias


@export var audio_weight_target: float = 0:
	set(value):
		if value > 1:
			value = 1
		if value < 0:
			value = 0
		audio_weight_target = value

@export var audio_weight: float = 0:
	set(value):
		if value > 1:
			value = 1
		if value < 0:
			value = 0
		audio_weight = value
		audio_weight_target = value
		if _track0:
			_track0.volume_db = linear_to_db(1 - audio_weight)
		if _track1:
			_track1.volume_db = linear_to_db(audio_weight)

@onready var _track0: AudioStreamPlayer = $Track0
@onready var _track1: AudioStreamPlayer = $Track1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	audio_weight = audio_weight
	
	_track0.stream = audio0
	_track1.stream = audio1
	_track0.play()
	_track1.play()
	pass # Replace with function body.

func _process(delta: float) -> void:
	if audio_weight != audio_weight_target:
		var delta_lerp: float = _delta_lerp_amount
		var delta_over_half: bool = _delta_lerp_amount > 0.5
		var towards_1: bool = audio_weight < audio_weight_target
		match _track_bias:
			TrackBias.NEITHER:
				pass
			TrackBias.AUDIO0:
				if towards_1:
					if delta_over_half:
						delta_lerp = 1 - delta_lerp
				elif !delta_over_half:
					delta_lerp = 1 - delta_lerp
			TrackBias.AUDIO1:
				if towards_1:
					if !delta_over_half:
						delta_lerp = 1 - delta_lerp
				elif delta_over_half:
					delta_lerp = 1 - delta_lerp
		print("track weight %.5f target %.5f delta_lerp %.2f" % [audio_weight, audio_weight_target, delta_lerp])
		audio_weight = lerpf(audio_weight, audio_weight_target, delta_lerp * delta)
	
	pass
