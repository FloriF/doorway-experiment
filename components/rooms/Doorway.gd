extends Node3D

func _on_detect_player_body_entered(body: Node3D) -> void:
	$MoveDoor.play("open")

func _on_detect_player_body_exited(body: Node3D) -> void:
	$MoveDoor.play_backwards("open")
