extends Window

func _ready() -> void:
	# show participant ID in window
	%ParticipantID.text = str(ExperimentLogic.participantID).pad_zeros(3)
	%NumberOfTrials.text = str(ExperimentLogic.total_number_of_trials).pad_zeros(3)

func _on_StartFirstTrial_pressed() -> void:
	# move the prepared trial to current
	var nextTrial = ExperimentLogic.getNextTrial()
	var currentTrialNode = ExperimentLogic.get_node("Trials").get_node("CurrentTrial") 
	nextTrial.reparent(currentTrialNode)
	# run the trial, e.g., move player into it
	ExperimentLogic.runCurrentTrial()
	$StartFirstTrial.disabled = true
