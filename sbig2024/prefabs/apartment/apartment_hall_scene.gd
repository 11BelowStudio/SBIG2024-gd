
class_name ApartmentHallScene
extends Node3D

@onready var enforcerDoor: DynamicDoor = %EnforcerDoor
@onready var apartmentDoor: DynamicDoor = %ApartmentDoor

@onready var sticker: UseGetSticker = $StickerGet

@onready var bedroomSpawn: Node3D = %BedroomSpawnPoint
@onready var hallSpawn: Node3D = %HallwaySpawnPoint

@onready var enforcerSpawn: Node3D = %EnforcerSpawn
@onready var enforcerMidHall: Node3D = %EnforcerMidHall

@onready var exitArea: Area3D = %ExitTrigger
@onready var doorArea: Area3D = %AptDoorTrigger
@onready var hallArea1: Area3D = %HallTrigger1
@onready var hallArea2: Area3D = %HallTrigger2
@onready var hallArea3: Area3D = %HallTrigger3

## vidscreen audio player
@onready var vidscreen_audio: AudioStreamPlayer3D = %VidscreenAudio
@onready var _vidscreen_model: MeshInstance3D = %Apartment/Node/DynamicFurniture/VidphoneDynamic/Screen
## the 'on' texture for the vidscreen
@export var _vidscreen_on_texture: BaseMaterial3D

## fpui instance
@onready var fpui: FPUI = $FPUI

@export var hide_sticker: bool = false

@export var discard_ui: bool = false

@export var _apartment_door_open: bool = false:
	set(value):
		_apartment_door_open = value
		set_apartment_door_open(value)

@export var _enforcer_door_open: bool = false:
	set(value):
		_enforcer_door_open = value
		set_enforcer_door_open(value)

## emitted when player in room
signal player_in_room

## emitted when player at door area
signal player_door_area

## emitted when player at hall area 1
signal player_hall_1

## emitted when player at hall area 2
signal player_hall_2

## emitted when player at hall area 3
signal player_hall_3

## emitted when player at exit area
signal player_exit_area


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if hide_sticker:
		sticker.sticker_shown = false
	
	if discard_ui:
		fpui.free()
		fpui = null
	
	set_apartment_door_open(_apartment_door_open)
	set_enforcer_door_open(_enforcer_door_open)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_exit_trigger_body_entered(body: Node3D) -> void:
	
	var player: FPCharacter = body as FPCharacter
	if player:
		player_exit_area.emit()
	
	pass # Replace with function body.


func _on_hall_trigger_3_body_entered(body: Node3D) -> void:
	
	var player: FPCharacter = body as FPCharacter
	if player:
		player_hall_3.emit()
	pass # Replace with function body.


func _on_hall_trigger_2_body_entered(body: Node3D) -> void:
	var player: FPCharacter = body as FPCharacter
	if player:
		player_hall_2.emit()
	pass # Replace with function body.


func _on_hall_trigger_1_body_entered(body: Node3D) -> void:
	var player: FPCharacter = body as FPCharacter
	if player:
		player_hall_1.emit()
	pass # Replace with function body.


func _on_apt_door_trigger_body_entered(body: Node3D) -> void:
	var player: FPCharacter = body as FPCharacter
	if player:
		player_door_area.emit()
	pass # Replace with function body.


func _on_in_room_trigger_body_entered(body: Node3D) -> void:
	var player: FPCharacter = body as FPCharacter
	if player:
		player_in_room.emit()
	pass # Replace with function body.


## call this to play some audio from the vidscreen (will also turn the vidscreen on)
func play_vidscreen_audio(play_this: AudioStream) -> void:
	vidscreen_audio.stream = play_this
	vidscreen_audio.play()
	_vidscreen_model.material_override = _vidscreen_on_texture
	pass


## when the vidscreen audio is over, we turn the vidscreen off.
func _on_vidscreen_audio_finished() -> void:
	_vidscreen_model.material_override = null
	pass # Replace with function body.


func set_apartment_door_open(open: bool) -> void:
	if apartmentDoor:
		apartmentDoor.set_open(open)

func set_enforcer_door_open(open: bool) -> void:
	if enforcerDoor:
		enforcerDoor.set_open(open)


func _on_use_get_sticker_sticker_obtained_signal() -> void:
	pass # Replace with function body.



