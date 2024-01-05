extends Window

func _ready() -> void:
	# show participant ID in window
	%ParticipantID.text = str(ExperimentLogic.participantID).pad_zeros(3)
	%NumberOfTrials.text = str(ExperimentLogic.total_number_of_trials).pad_zeros(3)

##################################################################################################

func _on_StartFirstTrial_pressed() -> void:
	# move the prepared trial to current
	var nextTrial = ExperimentLogic.getNextTrial()
	var currentTrialNode = ExperimentLogic.get_node("Trials").get_node("CurrentTrial") 
	nextTrial.reparent(currentTrialNode)
	# move player into the current trial and disable this button
	ExperimentLogic.addPlayerToCurrentTrial()
	$StartFirstTrial.disabled = true

func _on_height_calibration_pressed() -> void:
	# execute the height calibration function in the player script
	get_tree().call_group("player", "expCalibrateHeight")


func _on_trigger_toggle_toggled(button_pressed: bool) -> void:
	# execute the toggle_triggers function in the player script
	get_tree().call_group("player", "toggle_triggers", button_pressed)


func _on_trackpad_toggle_toggled(button_pressed: bool) -> void:
	# execute the toggle_trackpad function in the player script
	get_tree().call_group("player", "toggle_trackpad", button_pressed)


func _on_teleport_player_pressed() -> void:
	# get the position the player should be
	var target_transform = ExperimentLogic.getCurrentTrial().get_node("TrialSetup").\
											get_node("PlayerStartPosition").global_transform
	get_tree().call_group("player", "initiate_teleport", target_transform)
