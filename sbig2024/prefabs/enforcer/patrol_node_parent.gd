class_name PatrolNodeParent
extends Node3D

func get_patrol_nodes() -> Array[EnforcerPatrolNode]:
	var result: Array[EnforcerPatrolNode] = []
	for child in get_children():
		print("%s %s" % [child, child is EnforcerPatrolNode])
		if child is EnforcerPatrolNode:
			result.append(child)
	return result
