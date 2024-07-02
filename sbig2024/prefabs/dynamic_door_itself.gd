extends RigidBody3D

signal door_bumped

func bump() -> void:
	door_bumped.emit()
