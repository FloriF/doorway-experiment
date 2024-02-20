extends Node3D


func _on_response_area_body_entered(_body: Node3D) -> void:
	ExperimentLogic.getCurrentTrial().playerInResponseArea = true


func _on_response_area_body_exited(_body: Node3D) -> void:
	ExperimentLogic.getCurrentTrial().playerInResponseArea = false
