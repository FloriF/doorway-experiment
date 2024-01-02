extends Button


func _on_pressed() -> void:
	# execute the height calibration function in the player script
	get_tree().call_group("player", "expCalibrateHeight")
