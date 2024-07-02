@tool
extends StaticBody3D

@export var _meshParent: Node3D
@export var _shape: CollisionShape3D

@export var realScale: Vector3:
	set(value):
		realScale = value
		if _meshParent:
			_meshParent.scale = value / _initialBoxSize
		if _shape:
			var box: BoxShape3D = BoxShape3D.new()
			box.set_size(value)
			_shape.set_shape(box)
	get:
		var box: BoxShape3D = _shape.shape as BoxShape3D
		return box.size

@export var _pos: Vector3:
	set(value):
		position = value
	get:
		return position

@export_group("do not touch!")
## DO NOT MODIFY THIS WITHIN INSTANCES!
@export var _initialBoxSize: Vector3
