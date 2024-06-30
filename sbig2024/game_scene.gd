class_name GameScene
extends Node3D

@export var ambientAudio: AudioStreamPlayer

@export var standardAmbient: AudioStreamOggVorbis
@export var tenseAmbient: AudioStreamOggVorbis


@onready var heartbeater: Heartbeater = $Heartbeater
@onready var whitenoise: WhiteNoise = $WhiteNoise

@onready var character: FPCharacter = $Character


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var intensity: float = character.get_dist_intensity()
	
	heartbeater.intensity = intensity
	whitenoise.set_intensity01(intensity)
	
	pass
