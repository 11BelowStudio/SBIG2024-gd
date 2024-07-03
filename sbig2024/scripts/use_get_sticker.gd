
class_name UseGetSticker
extends StickerBase

@export var spin_duration: float = 5

@export var sticker_shown: bool = true:
	set(value):
		sticker_shown = value
		if visual:
			visual.visible = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
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
