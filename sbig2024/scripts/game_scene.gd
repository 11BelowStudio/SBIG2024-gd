class_name GameScene
extends Node3D

@export var ambientAudio: AudioStreamPlayer

@export var standardAmbient: AudioStreamOggVorbis
@export var tenseAmbient: AudioStreamOggVorbis


@onready var heartbeater: Heartbeater = $Heartbeater
@onready var whitenoise: WhiteNoise = $WhiteNoise
@onready var dualAmbience: TwoTrackAmbience = $TwoTrackAmbience


@onready var theSticker: TheSticker = $TheSticker

@onready var character: FPCharacter = $Character


@onready var sticker_placed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	character.look_target = theSticker
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var intensity: float = character.get_dist_intensity()
	
	heartbeater.intensity_target = intensity
	dualAmbience.audio_weight_target = intensity
	#whitenoise.set_intensity01(intensity)
	
	pass

func _on_sticker_placed() -> void:
	
	heartbeater.intensity_target = 0
	dualAmbience.audio_weight_target = 0
	character.look_target = null
	
	pass
