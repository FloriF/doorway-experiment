extends Window

func _ready() -> void:
	# show participant ID in window
	%ParticipantID.text = str(ExperimentLogic.participantID).pad_zeros(3)
	%NumberOfTrials.text = str(ExperimentLogic.total_number_of_trials).pad_zeros(3)

## @experimental #TODO this is just a testing button
func _on_button_pressed() -> void:
	var trial = ExperimentLogic.pickRandomTrial()
	ExperimentLogic.setCurrentTrial(trial)
	ExperimentLogic.startCurrentTrial()
	#await get_tree().create_timer(4.0).timeout
	#ExperimentLogic.completeCurrentTrial()


func _on_button_2_pressed() -> void:
	var trial = ExperimentLogic.pickRandomTrial()
	ExperimentLogic.setCurrentTrial(trial)
	ExperimentLogic.startCurrentTrial()
	#await get_tree().create_timer(4.0).timeout
	ExperimentLogic.errorTrial("debug_button")
