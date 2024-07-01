
class_name TheSticker
extends StaticBody3D

@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _shape: CollisionShape3D = $CollisionShape3D

@onready var _doneNoise: AudioStreamPlayer3D = $DoneNoisePlayer
@onready var _placingNoise: AudioStreamPlayer3D = $PlacingNoisePlayer

var _stickered: bool = false


## emitted when the sticker gets placed
signal sticker_placed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	_mesh.visible = false
	_stickered = false
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func placing_started() -> void:
	_placingNoise.play()
	

func placing_aborted() -> void:
	_placingNoise.stop()


func use() -> void:
	print("use called on the sticker!")
	_placingNoise.stop()
	
	if _stickered:
		return
	_doneNoise.play()
	_stickered = true
	_mesh.visible = true
	sticker_placed.emit()

