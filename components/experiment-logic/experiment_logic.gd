extends Node

# set and changed before the experiment
var participantID : int = 0
var newTrial = load("res://components/experiment-logic/trial.tscn")
var trial_number : int = 1
var total_number_of_trials : int = 0
var number_of_error_trials : int = 0

# player scene
var player = preload("res://components/player/player.tscn").instantiate()

# lists of object paths and names and rooms
var stimulusObjects_LivingRoom : Array = []
var stimulusObjects_Workshop : Array = []
var living_room_variations : Array = []
var workshop_variations : Array = []

# fixed experiment settings
const ROOM_CONTEXT = ["LivingRoom", "Workshop"]
const DOORWAY_CONDITION = ["Doorway", "NoDoorway"]
const REPETITIONS = 1 # how many times each condition is repeated
const NUMBER_OF_OBJECTS = 5 # how many of the 7 locations should contain an object?

const MAX_MOVEMENT_TIME = 10 # maximum time allowed to move between item displays
const MAX_RESPONSE_TIME = 5 # maximum time to give a response after seeing the objects
const MAX_CONFIDENCE_TIME = 5 # maximum time to give a confidence response

# next to the final executable, the datafiles will be created
const SAVE_DATA_PATH :String = "./data_"
var saveFile : String = ""

####################################################################################################

# runs at the very beginning (-> autoload)
func _ready() -> void:
	# initialize random number generator
	randomize()
	# seed(1) # for testing purposes only!
	# prepare lists of possible objects to present
	stimulusObjects_LivingRoom = _getStimulusObjects("res://components/stimulus-objects/living-room/")
	stimulusObjects_Workshop = _getStimulusObjects("res://components/stimulus-objects/workshop/")
	# prepare lists of available room variations
	living_room_variations = _getStimulusObjects("res://components/rooms/living-room/")
	workshop_variations = _getStimulusObjects("res://components/rooms/workshop/")

func prepareSaveData() -> void:
	saveFile = SAVE_DATA_PATH + "doorway_" + str(participantID).pad_zeros(3) + ".json"
	var file : RefCounted
	# check if the save file already exists
	if FileAccess.file_exists(saveFile):
		# NOTE this does NOT stop the experiment code from continuing, it is just to inform
		# the experimenter of the mistake and gives a chance to stop:
		_alertIDExists()
		
		# READ_WRITE does not delete the previous file content, so entering an ID that already exists
		# does not delete all the data, but the file has to be handled manually later
		file = FileAccess.open(saveFile, FileAccess.READ_WRITE)
	else:
		# create a new file
		file = FileAccess.open(saveFile, FileAccess.WRITE)
		
	# possibly add general participant information TODO
	
	# close file
	file.close()

# popup information if data for participant already exists
func _alertIDExists() -> void:
	var dialog = ConfirmationDialog.new()
	var overwrite : bool = false
	
	# first, prepare the dialog box
	dialog.dialog_text = "Participant ID " + str(participantID).pad_zeros(3) + \
						  " already in use. Continuing will append new data to the existing file."
	dialog.cancel_button_text = "Quit Experiment"
	# connect a signal which is triggered on cancel button press, and calls endExperiment 
	dialog.get_cancel_button().pressed.connect(_on_Dialog_cancelled)
	
	dialog.ok_button_text = "Continue"
	# do nothing on click, just continue
	
	# second, add popup to scene tree and display it
	dialog.always_on_top = true
	add_child(dialog)
	dialog.popup_centered()
	
# only gets called from the dialog informing of already existing datafiles
func _on_Dialog_cancelled() -> void:
	endExperiment()

# loop over all possible condition combinations and add a trial for each
# this also creates repeated trials
func prepareTrials() -> void:
	for first_room in ROOM_CONTEXT:
		for doorway in DOORWAY_CONDITION:
			for second_room in ROOM_CONTEXT:
				# create multiple repetitions of each condition combination
				for i in range(REPETITIONS):
					# create a new trial
					var addedTrial = newTrial.instantiate()
					# create an array containing the conditions where the objects come from
					# TODO for now, this is just both. could be introduced as a balanced experimental
					# condition, but this results in more trials necessary (3x: only Livg., only Works., both)
					var objectContexts : Array = ["LivingRoom", "Workshop"]
					# set this trial's conditions
					addedTrial.set_conditions(first_room, doorway, second_room, NUMBER_OF_OBJECTS, objectContexts)
					# add this trial to the list of future trials
					# 'true' forces a readable name (Trial7 instead of @Node485 or whatever)
					$Trials/FutureTrials.add_child(addedTrial, true)
	# finally, also for tracking purposes, give the amount of trials created
	total_number_of_trials = $Trials/FutureTrials.get_child_count()

# picks a random trial from either the future trials or the error trials that have to be repeated
func pickRandomTrial() -> Node:
	# initially, only take trials from the list of trials created at the start of the experiment
	var NodeWithTrials = $Trials/FutureTrials
	# if there are no more future trials, check if any are in the ErrorTrials group
	if NodeWithTrials.get_child_count() == 0:
		NodeWithTrials = $Trials/ErrorTrials
		# if there are also no more error trials to be repeated
		if NodeWithTrials.get_child_count() == 0:
			endExperiment()
	# get number of trials in this node and select by "random number modulo the number of trials"
	# this way, regardless of which random number is generated, there is always a valid trial/index
	var randomTrialID : int = randi() % NodeWithTrials.get_child_count()
	# return the Trial node
	return NodeWithTrials.get_child(randomTrialID)

# moves a trial into the current trial node and increases the trial counter
# NOTE this does not start the trial!
# ALERT this should now be handled differently, since we have a NextTrial
#func setCurrentTrial(TrialNode) -> void:
	## move the given trial to the currentTrial group
	#TrialNode.reparent($Trials/CurrentTrial)
	## give this trial a number
	#TrialNode.trial_number = trial_number
	## increase the trial number counter
	#trial_number += 1

# run the current trial
func runCurrentTrial() -> void:
	var currentTrial = getCurrentTrial()
	
	#TODO
	#TODO
	#TODO


# these functions can be called by buttons to get the trial information
func getCurrentTrial() -> Node:
	return $Trials/CurrentTrial.get_child(0)
	
func getNextTrial() -> Node:
	return $Trials/NextTrial.get_child(0)
	
func setNextTrial(trial) -> void:
	trial.reparent($Trials/NextTrial)

func setCurrentTrial(trial) -> void:
	trial.reparent($Trials/CurrentTrial)

# gets stimulus scene names (objects + rooms) from their folders
func _getStimulusObjects(pathToObjectFolder) -> Array:
	var listOfObjects : Array = []
	var dir = DirAccess.open(pathToObjectFolder)
	# start listing all files in folder
	dir.list_dir_begin()
	# get next available filename in directory
	var filename = dir.get_next()
	
	# as long as there is a file
	while filename != "":
		#print(filename)
		# add this file to the list
		listOfObjects.append(dir.get_current_dir() + "/" + filename)
		# get the next file in the directory
		filename = dir.get_next()
	# end listing files in this directory
	dir.list_dir_end()
	return listOfObjects

func endExperiment() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	
	
	
	
	
	
	
	
	
	
	
	
########################### all stuff below should be moved to the trial node

# TODO there should be more happening on the trial start!
func startCurrentTrial() -> void:
	var currentTrial = getCurrentTrial()
	pass
	

# trial has to be repeated
func errorTrial(error_info) -> void:
	var currentTrial = getCurrentTrial()
	# write reason for error into trial data
	currentTrial.error_info = error_info
	# save the data for this trial
	saveTrial(currentTrial)
	# increase counter for trial presentations
	currentTrial.repetition += 1
	# track the number of trials that have to be repeated for monitoring during experiment
	number_of_error_trials += 1
	# stop trial timer
	currentTrial.stopTimer()
	# move to error group
	currentTrial.reparent($Trials/ErrorTrials)

	
func saveTrial(currentTrial) -> void:
	var currentTrialSaveData = currentTrial.getTrialSaveData()
	# make JSON string (sort: false, full_precision: true)
	var currentTrialSaveDataJSON = JSON.stringify(currentTrialSaveData, "", false, true)
	print(currentTrialSaveDataJSON)
	# actually save the data to the save file
	var file = FileAccess.open(saveFile, FileAccess.READ_WRITE)
	# jump to end of file
	file.seek_end(-1)
	# write data to file
	file.store_line(currentTrialSaveDataJSON)
	# add a new line
	file.store_line("\n")
	# (not necessary) close file
	file.close()

# trial has been completed successfully
func completeCurrentTrial() -> void:
	var currentTrial = getCurrentTrial()
	# save the data for this trial
	saveTrial(currentTrial)
	# stop the trial timer
	currentTrial.stopTimer()
	# there should only ever be one trial in here, so we get this trial and move it to the completed group
	currentTrial.reparent($Trials/CompletedTrials)


