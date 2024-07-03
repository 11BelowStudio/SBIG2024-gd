extends Node

signal level_won
signal level_lost

@export var vidscreen_sound: AudioStream

@onready var character: FPCharacter = $Character
@onready var apartment: ApartmentHallScene = $ApartmentHallScene

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

enum Scene4State {
	SPAWNED,
	STICKER_GOT,
	IN_HALLWAY,
	HALL_1,
	HALL_2,
	HALL_3,
	DONE
}

@export var _state: Scene4State = Scene4State.SPAWNED

@export var _instruction_1: String = "Grab the sticker."
@export var _instruction_2: String = "Hold E to take the sticker."
@export var _instruction_3: String = "Time to go."


@export var _sticker_duration: float = 3
@export var _sticker_progress: float = 0
@export var _sticker_decay_delta: float = 0.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	character.holding_sticker = false
	apartment.fpui.progress.max_value = _sticker_duration
	apartment.fpui.show_instruction(_instruction_1)
	apartment.play_vidscreen_audio(vidscreen_sound)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if _state == Scene4State.SPAWNED:
		match sticker_state:
			StickerStates.NOT_DONE:

				_sticker_progress = lerpf(_sticker_progress, 0, _sticker_decay_delta * delta)
				apartment.fpui.progress.value = _sticker_progress
			StickerStates.DOING:
				_sticker_progress += delta
				apartment.fpui.progress.value = _sticker_progress
				if _sticker_progress >= _sticker_duration:
					_sticker_got()
			_:
				pass
		pass
	
	pass

func _physics_process(delta: float) -> void:
	if _state == Scene4State.SPAWNED:
		match sticker_state:
			StickerStates.NOT_DONE:
				var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
				if characterUseObj and characterUseObj == apartment.sticker:
					apartment.fpui.show_instruction(_instruction_2)
					if Input.is_action_just_pressed(character.USE):
						sticker_state = StickerStates.DOING
						#theSticker.placing_started()
				else:
					apartment.fpui.show_instruction(_instruction_1)
			StickerStates.DOING:
				if Input.is_action_pressed(character.USE):
					var characterUseObj: StickerBase = character.get_use_raycast_target() as StickerBase
					if (not characterUseObj) or (characterUseObj != apartment.sticker):
						sticker_state = StickerStates.NOT_DONE
						#theSticker.placing_aborted()
				else:
					sticker_state = StickerStates.NOT_DONE
					#theSticker.placing_aborted()
			_:
				pass
		pass

func _sticker_got() -> void:
	if _state == Scene4State.SPAWNED:
		_state = Scene4State.STICKER_GOT
		apartment.fpui.show_instruction(_instruction_3)
		apartment.sticker.use()
		apartment.apartmentDoor.open_door()
		character.holding_sticker = true
	pass

func _on_apartment_hall_scene_player_door_area() -> void:
	if _state == Scene4State.STICKER_GOT:
		apartment.fpui.hide_instruction()
		_state = Scene4State.IN_HALLWAY
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_1() -> void:
	if _state == Scene4State.IN_HALLWAY:
		#apartment.fpui.show_intro_a(_intro_text_1)
		_state = Scene4State.HALL_1
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_2() -> void:
	if _state == Scene4State.HALL_1:
		#apartment.fpui.show_intro_a(_intro_text_2)
		_state = Scene4State.HALL_2
	pass # Replace with function body.


func _on_apartment_hall_scene_player_hall_3() -> void:
	if _state == Scene4State.HALL_2:
		#apartment.fpui.show_intro_a("")
		#apartment.fpui.show_intro_b(_intro_text_3)
		_state = Scene4State.HALL_3
	pass # Replace with function body.

func _on_apartment_hall_scene_player_exit_area() -> void:
	if _state != Scene4State.DONE:
		_state = Scene4State.DONE
		level_won.emit()
	pass # Replace with function body.
