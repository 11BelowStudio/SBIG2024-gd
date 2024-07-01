

class_name StaticGamestate
extends Node

enum GameState {
	ApartmentOut1,
	Sticker1,
	ApartmentIn1,
	ApartmentOut2,
	Sticker2,
	ApartmentIn2,
	ApartmentOut3,
	Sticker3,
	ApartmentIn3
}

@export var _game_state: GameState = GameState.ApartmentOut1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
