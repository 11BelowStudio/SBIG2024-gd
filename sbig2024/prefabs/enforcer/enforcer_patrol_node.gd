class_name EnforcerPatrolNode
extends StaticBody3D

@onready var _nearbyCast = $NearbyCast

## obtains the nearby patrol nodes to this one
func get_nearby_nodes() -> Array[EnforcerPatrolNode]:
	if !_nearbyCast.is_colliding():
		return []
	var result: Array[EnforcerPatrolNode] = []
	for index in _nearbyCast.get_collision_count():
		var near_node: EnforcerPatrolNode = _nearbyCast.get_collider(index) as EnforcerPatrolNode
		if near_node:
			result.append(near_node)
	return result

