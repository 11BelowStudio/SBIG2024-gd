
class_name ApartmentHallScene
extends Node3D

@onready var enforcerDoor: DynamicDoor = %EnforcerDoor

@onready var apartmentDoor: DynamicDoor = %ApartmentDoor

@onready var sticker: UseGetSticker = $use_get_sticker

@onready var bedroomSpawn: Node3D = %BedroomSpawnPoint

@onready var hallSpawn: Node3D = %HallwaySpawnPoint

@onready var enforcerSpawn: Node3D = %EnforcerSpawn

@onready var exitArea: Area3D = %ExitTrigger

@onready var doorArea: Area3D = %AptDoorTrigger

@onready var hallArea1: Area3D = %HallTrigger1

@onready var hallArea2: Area3D = %HallTrigger2
@onready var hallArea3: Area3D = %HallTrigger3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
