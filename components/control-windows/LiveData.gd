extends VBoxContainer

# this is called continuously while the experiment is running
func _process(delta: float) -> void:
	# trial counting
	# also track error trials
	var total_trials_with_error = ExperimentLogic.total_number_of_trials + ExperimentLogic.number_of_error_trials
	%CurrentTrialNumber.text = str(ExperimentLogic.trial_number - 1).pad_zeros(3)
	%NumberOfTrials.text = str(total_trials_with_error).pad_zeros(3)
	
	# experiment progress bar
	$ProgressBar.value = ExperimentLogic.trial_number - 1
	$ProgressBar.max_value = total_trials_with_error
