
class_name WhiteNoise
extends AudioStreamPlayer

@export var target_filter_hz: float = 0

@export var wnoise_filter_res: float = 0.45

@export var _max_filter_hz: float = 5000

@export var _filter_target_lerp: float = 0.45

var wnoise_filter: AudioEffectFilter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var wnoise_bus_index:int = AudioServer.get_bus_index(self.bus)
	
	#print(AudioServer.get_bus_effect_count(wnoise_bus_index))
	for i in range(AudioServer.get_bus_effect_count(wnoise_bus_index)):
		var bus_effect: AudioEffect = AudioServer.get_bus_effect(wnoise_bus_index, i)
		
		if ClassDB.is_parent_class(bus_effect.get_class(), "AudioEffectFilter"):
			wnoise_filter = bus_effect as AudioEffectFilter
			wnoise_filter.cutoff_hz = target_filter_hz
			wnoise_filter.resonance = wnoise_filter_res
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wnoise_filter.cutoff_hz = lerpf(wnoise_filter.cutoff_hz, target_filter_hz, _filter_target_lerp)
	pass

## call this to set the intensity of the noise (as a value between 0 and 1)
func set_intensity01(intensity01: float) -> void:
	target_filter_hz = minf(_max_filter_hz, _max_filter_hz * intensity01)
	if target_filter_hz < 0:
		target_filter_hz = 0
