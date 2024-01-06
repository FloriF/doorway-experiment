extends Window

# INFO ExperimentLogic is an autoload script, so it is available from everywhere!

# create instances of scenes to be loaded later
var experiment_control_window = preload("res://components/control-windows/experiment-control-window.tscn").instantiate()
var player = preload("res://components/player/player.tscn").instantiate()

###################################################################################################

func _on_start_experiment_pressed() -> void:
	# put startup window input into experiment logic
	ExperimentLogic.participantID = $CenterVertically/CenterHorizontally/ParticipantID.value
	# create save data file for this participant
	ExperimentLogic.prepareSaveData()
	# create trials
	ExperimentLogic.prepareTrials(ExperimentLogic.REPETITIONS, ExperimentLogic.get_node("Trials").get_node("ExperimentTrials"))
	
	# create training trials
	ExperimentLogic.prepareTrials(1, ExperimentLogic.get_node("Trials").get_node("TrainingTrials"))
	
	# get trial counts
	ExperimentLogic.countTrials()
	
	# add the experiment control window to the scene
	get_tree().root.add_child(experiment_control_window)
	
	# prevent start button to be pressed again
	$CenterVertically/StartExperiment.text = "EXPERIMENT RUNNING"
	$CenterVertically/StartExperiment.disabled = true
	$CenterVertically/CenterHorizontally/ParticipantID.editable = false
	
	##########################

	# put the player node into currentplayer
	ExperimentLogic.currentPlayerNode = player	
	
	# prepare the first trial
	# get a random trial and make it the next trial
	ExperimentLogic.setNextTrial(ExperimentLogic.pickRandomTrial())
	# instantiate the current trial
	ExperimentLogic.getNextTrial()._populateTrial()
	
