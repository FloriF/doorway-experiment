extends Node3D


func _on_response_area_body_entered(body: Node3D) -> void:
	ExperimentLogic.getCurrentTrial().playerInResponseArea = true


func _on_response_area_body_exited(body: Node3D) -> void:
	ExperimentLogic.getCurrentTrial().playerInResponseArea = false
