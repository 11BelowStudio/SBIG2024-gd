class_name FPScene
extends BaseScene

enum StickerStates { NOT_DONE, DOING, DONE }

var sticker_state: StickerStates = StickerStates.NOT_DONE

@export var sticker_duration: float = 3
@export var sticker_progress: float = 0
@export var sticker_decay_delta: float = 0.9

@onready var theSticker: StickerBase = %StickerPlace

@onready var ui: FPUI = $FPUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
