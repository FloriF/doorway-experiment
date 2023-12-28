extends Node3D

# this is called by the button press
func present_objects() -> void:
	# open the lid (takes 1 sec)
	open_lid()
	# start the timer at the same time
	# after 2 sec, the times will run out and close the lid again
	# so the total time objects are at least partially visible is 3 seconds:
	# 2 seconds (Timer + open lid) + 1 second (close lid), since the animations take a little time
	$item_display_lid/Timer.start()

func open_lid() -> void:
	$item_display_lid/LidMovement.play("opening")
	
func close_lid() -> void:
	$item_display_lid/LidMovement.play_backwards("opening")

func _on_timer_timeout() -> void:
	close_lid()
