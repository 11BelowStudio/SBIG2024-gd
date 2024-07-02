# crappy thing I bodged together to hopefully allow the cubes to be resizable I guess?
@tool

extends StaticBody3D

@export var _mesh: MeshInstance3D
@export var _shape: CollisionShape3D

# The real scale that's used on the backend
@export var realScale: Vector3:
	set(value):
		realScale = value
		if _mesh:
			_mesh.scale = value
		if _shape:
			var box: BoxShape3D = BoxShape3D.new()
			box.set_size(value)
			_shape.set_shape(box)
		# return
