
class_name UseGetSticker
extends StaticBody3D

@onready var visual: MeshInstance3D = $sticker_get_visual

@onready var audio: AudioStreamPlayer3D = $StickerAudio

@export var spin_duration: float = 5

@export var sticker_shown: bool = true:
	set(value):
		sticker_shown = value
		if visual:
			visual.visible = value


signal sticker_obtained_signal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visual.visible = sticker_shown
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if visual.visible:
		visual.rotate_y((TAU / spin_duration) * delta)
	pass

func use() -> void:
	visual.visible = false
	
	pass
