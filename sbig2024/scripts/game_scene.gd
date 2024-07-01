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

@onready var stickerProgress: CircularProgressBar = $UI/StickerProgressBar
@onready var instructionLabel: Label = $UI/InstructionLabel

@export var _instruction_1: String = "Act natural, walk up to the wall, get it done."
@export var _instruction_2: String = "Get a bit closer, keep an eye out for enforcers (Q)..."
@export var _instruction_3: String = "Hold E to stick."
@export var _instruction_4: String = "Keep calm, walk away, act natural..."


@export var USE : String = "use"

@export var _sticker_placing_duration: float = 3
@export var _sticker_placing_progress: float = 0
@export var _sticker_placing_decay_delta: float = 0.9

enum StickerStates { NOT_PLACED, PLACING, PLACED }

var sticker_state: StickerStates = StickerStates.NOT_PLACED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	character.look_target = theSticker
	character.holding_sticker = true
	stickerProgress.max_value = _sticker_placing_duration
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var intensity: float = character.get_dist_intensity()
	
	heartbeater.intensity_target = intensity
	dualAmbience.audio_weight_target = intensity
	#whitenoise.set_intensity01(intensity)
	
	match sticker_state:
		StickerStates.NOT_PLACED:
			
			if intensity == 0:
				instructionLabel.text = _instruction_1
			elif (intensity >= 0.35) and (intensity <= 0.8):
				instructionLabel.text = _instruction_2
			
			_sticker_placing_progress = lerpf(_sticker_placing_progress, 0, _sticker_placing_decay_delta * delta)
			stickerProgress.value = _sticker_placing_progress
		StickerStates.PLACING:
			_sticker_placing_progress += delta
			stickerProgress.value = _sticker_placing_progress
			if _sticker_placing_progress >= _sticker_placing_duration:
				_sticker_placed()
		_:
			pass
	pass
	
	#print("progress: %1.3f state: %s" % [_sticker_placing_progress, sticker_state])



func _physics_process(delta: float) -> void:
	
	match sticker_state:
		StickerStates.NOT_PLACED:
			var characterUseObj: TheSticker = character.get_use_raycast_target() as TheSticker
			if characterUseObj and characterUseObj == theSticker:
				instructionLabel.text = _instruction_3
				if Input.is_action_just_pressed(USE):
					sticker_state = StickerStates.PLACING
					theSticker.placing_started()
			else:
				instructionLabel.text = _instruction_2
		StickerStates.PLACING:
			if Input.is_action_pressed(USE):
				var characterUseObj: TheSticker = character.get_use_raycast_target()  as TheSticker
				if (not characterUseObj) or (characterUseObj != theSticker):
					sticker_state = StickerStates.NOT_PLACED
					theSticker.placing_aborted()
			else:
				sticker_state = StickerStates.NOT_PLACED
				theSticker.placing_aborted()
		_:
			pass
	
	
	pass


func _sticker_placed() -> void:
	theSticker.use()
	character.holding_sticker = false
	sticker_state = StickerStates.PLACED
	heartbeater.intensity_target = 0
	dualAmbience.audio_weight_target = 0
	character.look_target = null
	instructionLabel.text = _instruction_4

func _on_sticker_placed() -> void:
	sticker_state = StickerStates.PLACED
	heartbeater.intensity_target = 0
	dualAmbience.audio_weight_target = 0
	character.look_target = null
	
	pass
