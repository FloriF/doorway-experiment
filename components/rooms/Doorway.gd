extends Node3D

func _ready() -> void:
	# set wait time for the door
	$MoveDoor/Timer.wait_time = ExperimentLogic.DOOR_WAIT_TIME

func _on_detect_player_body_entered(body: Node3D) -> void:
	# start short timer so participant has to wait at the boundary a little bit
	$MoveDoor/Timer.start()


func _on_detect_player_body_exited(body: Node3D) -> void:
	$MoveDoor.play_backwards("open")

# open door after timer  runs out
func _on_timer_timeout() -> void:
	$MoveDoor.play("open")
