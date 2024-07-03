
class_name StickerBase
extends StaticBody3D

signal sticker_done

@onready var _in_progress_noise: AudioStreamPlayer3D = $ProgressNoisePlayer
@onready var _done_noise: AudioStreamPlayer3D  = $DoneNoisePlayer

@onready var visual: Node3D = $StickerVisual

@export var _start_visible: bool

@export var stickered: bool = false



func _ready() -> void:
	stickered = false
	visual.visible = _start_visible

func start_stickering() -> void:
	_in_progress_noise.play()
	

func abort_stickering() -> void:
	_in_progress_noise.stop()


func use() -> void:
	print("use called on the sticker!")
	_in_progress_noise.stop()
	
	if stickered:
		return
	_done_noise.play()
	stickered = true
	visual.visible = !_start_visible
	sticker_done.emit()
