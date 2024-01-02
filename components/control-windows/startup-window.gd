extends Window

# INFO ExperimentLogic is an autoload script, so it is available from everywhere!

# create instances of scenes to be loaded later
var empty_scene = preload("res://components/rooms/empty_scene.tscn").instantiate()
var experiment_control_window = preload("res://components/control-windows/experiment-control-window.tscn").instantiate()

func _on_start_experiment_pressed() -> void:
	# put startup window input into experiment logic
	ExperimentLogic.participantID = $CenterVertically/CenterHorizontally/ParticipantID.value
	# create save data file for this participant
	ExperimentLogic.prepareSaveData()
	# create trials
	ExperimentLogic.prepareTrials()
	
	# add the experiment control window to the scene
	get_tree().root.add_child(experiment_control_window)

	# add empty starting scene
	get_tree().root.add_child(empty_scene)
	# prevent start button to be pressed again
	$CenterVertically/StartExperiment.text = "EXPERIMENT RUNNING"
	$CenterVertically/StartExperiment.disabled = true
	$CenterVertically/CenterHorizontally/ParticipantID.editable = false
	
	# add the participant/player to the scene
	get_tree().root.get_node("EmptyScene").get_node("PlayerStartPosition").add_child(ExperimentLogic.player)
