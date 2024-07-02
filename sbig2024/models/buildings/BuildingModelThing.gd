@tool
extends StaticBody3D

@export var _meshParent: Node3D
@export var _shape: CollisionShape3D

## DO NOT MODIFY THIS WITHIN INSTANCES!
@export var _initialBoxSize: Vector3

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
