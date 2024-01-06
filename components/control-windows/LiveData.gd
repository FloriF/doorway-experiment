extends VBoxContainer

# this is called continuously while the experiment is running
func _process(delta: float) -> void:
	# trial counting
	# also track error trials, so the total goes up if a trial has to be erepeated
	var total_trials_with_error = ExperimentLogic.total_number_of_training_trials + \
									ExperimentLogic.number_of_error_training_trials
	
	# training progress bar
	$TrainingTrials/CurrentTrialNumber.text = str(ExperimentLogic.trial_number - 1).pad_zeros(3)
	$TrainingTrials/NumberOfTrials.text = str(total_trials_with_error).pad_zeros(3)
	$ProgressBarTraining.value = ExperimentLogic.trial_number - 1
	$ProgressBarTraining.max_value = total_trials_with_error
	
	var n_training_trials = total_trials_with_error
	
	# now switch to counting only the experiment trials
	total_trials_with_error = ExperimentLogic.total_number_of_trials + ExperimentLogic.number_of_error_trials
	# experiment progress bar
	# also, we need to remove the amount of training trials to be correct
	$ExperimentTrials/CurrentTrialNumber.text = str(ExperimentLogic.trial_number - n_training_trials - 1).pad_zeros(3)
	$ExperimentTrials/NumberOfTrials.text = str(total_trials_with_error).pad_zeros(3)
	$ProgressBarExperiment.value = ExperimentLogic.trial_number - n_training_trials - 1
	$ProgressBarExperiment.max_value = total_trials_with_error
	
	# current performance
	$PerformanceCorrect.max_value = ExperimentLogic.trial_number - 1
	$PerformanceCorrect.value = ExperimentLogic.correct_trials
