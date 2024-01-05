extends Node3D

func _ready() -> void:
	# get the experiment timer settings
	
	# default animation duration is 1 second
	# so if it should take 2 seconds, play at half speed -> 1/value
	$item_display_lid/LidMovement.speed_scale = 1 /	ExperimentLogic.DISPLAY_OPENING_TIME
	
	# stay time starts after animation of opening is complete
	# however, the timer starts at the same time as the opening animation, so we have to add both here
	$item_display_lid/Timer.wait_time = ExperimentLogic.DISPLAY_STAY_TIME + ExperimentLogic.DISPLAY_OPENING_TIME 

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
	
func close_lid(speed: float = 1.0) -> void:
	$item_display_lid/LidMovement.play_backwards("opening")

###################################################################################################

func _on_timer_timeout() -> void:
	close_lid()
