extends CheckButton

func _on_toggled(button_pressed: bool) -> void:
	# execute the toggle_vignette_visibility function in the player script
	get_tree().call_group("player", "toggle_vignette_visibility")
