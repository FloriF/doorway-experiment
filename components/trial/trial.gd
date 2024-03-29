extends Node

# general information for this trial
var first_room : String = ""
var doorway : String = ""
var second_room : String = ""
var trial_number : int = 0
var number_of_objects : int = 0
var object_contexts : Array = []
var objects_changed : bool = false
var switched_locations : String = ""
var trialtype : String = ""

# data collected for this trial
var respone_objects_have_changed : bool = false 
var response_time : float = 0 
var confidence : int = 0 
var confidence_time : float = 0 
var playerInResponseArea : bool = false

# count additional presentations due to errors (not wrong answers!)
var repetition : int = 0
var error_info : String = ""

###################################################################################################

func _ready() -> void:
	# initialize stuff
	# get max timer values in case they have changed
	$MovementTimer.wait_time = ExperimentLogic.MAX_MOVEMENT_TIME
	$ResponseTimer.wait_time = ExperimentLogic.MAX_RESPONSE_TIME
	$ConfidenceTimer.wait_time = ExperimentLogic.MAX_CONFIDENCE_TIME
	# reset response area for this trial
	playerInResponseArea = false
	
# this is called to set all necessary information for the current trial
func set_conditions(c_room_1, c_doorway, c_room_2, c_number_of_objects, c_object_contexts, c_objects_changed) -> void:
	# assign the values to the variables from above
	first_room = c_room_1
	doorway = c_doorway
	second_room = c_room_2
	number_of_objects = c_number_of_objects
	object_contexts = c_object_contexts
	objects_changed = c_objects_changed
	
func validTrial() -> void:
	# save trial data to file
	_saveTrial()
	# LiveData information for average correctness
	if objects_changed == respone_objects_have_changed:
		ExperimentLogic.correct_trials += 1
	ExperimentLogic.currentPlayerNode.fadeToBlack()
	# wait to let button movement animations finish (XR interactable areas buttons might throw an error if not done)
	await get_tree().create_timer(0.5).timeout
	# move the trial to the completed trial group
	self.reparent(ExperimentLogic.get_node("Trials").get_node("CompletedTrials"))
	_endTrial("valid")
	
func errorTrial(error_str: String = "") -> void:
	# save the reason for error
	error_info = error_str
	# track the number of trials that have to be repeated for monitoring during experiment
	if trialtype == "ExperimentalTrial":
		ExperimentLogic.number_of_error_trials += 1
	if trialtype == "TrainingTrial":
		ExperimentLogic.number_of_error_training_trials += 1
	# save trial data to file
	_saveTrial()
	# increase the repetitions counter for this trial
	repetition += 1
	# reset the error string
	error_info = ""
	# wait to let button movement animations finish (XR interactable areas buttons might throw an error if not done)
	await get_tree().create_timer(0.5).timeout
	# the trial will be repeated, so we need to remove all objects
	# the trial will be populated again when it is picked to be presented
	_depopulateTrial()
	# move the trial to the error trial group
	self.reparent(ExperimentLogic.get_node("Trials").get_node("ErrorTrials"))
	
	_endTrial("error")
	
###################################################################################################

# this should only be called for the current/next trial, since this instantiates all objects, rooms
# and decoration objects within the rooms
func _populateTrial() -> void:
	# draw random objects
	_populateObjectLayout(number_of_objects, object_contexts)
	# draw room variations
	_populateRooms(first_room, second_room, doorway)

# remove all objects so they can be re-instanced later
# this is mostly used to save performance if many trials have to be repeated
func _depopulateTrial() -> void:
	# remove the doorway (if there is one!) and the two rooms with everything in them
	if $TrialSetup/PositionDoorway.get_child_count() != 0:
		$TrialSetup/PositionDoorway.get_child(0).free()
	$TrialSetup/PositionRoom1.get_child(0).free()
	$TrialSetup/PositionRoom2.get_child(0).free()
	# remove the objects by looping over all locations
	var possibleLocations = $ObjectLayout.get_children()
	for location in possibleLocations:
		# if there is an object, delete it
		if location.get_child_count() != 0:
			location.get_child(0).free()

# draw random objects and put them at random positions
func _populateObjectLayout(numberOfObjects, objectContexts) -> void:
	# select random locations that should hold an object
	var possibleLocations = $ObjectLayout.get_children()
	# randomize the order of the locations in this list
	possibleLocations.shuffle()
	# make the list smaller (-> remove last few (random) locations)
	# this creates empty spaces at random locations
	possibleLocations.resize(numberOfObjects)
	
	# get a copy of the list of possible objects (to not accidentally remove objects from the original list)
	var livingroom_objects = ExperimentLogic.stimulusObjects_LivingRoom.duplicate()
	var workshop_objects = ExperimentLogic.stimulusObjects_Workshop.duplicate()
	var objects : Array =  []
	
	# depending on the contexts given, add either one or both lists to the final object selection
	if objectContexts.has("LivingRoom"):
		objects.append_array(livingroom_objects)
	if objectContexts.has("Workshop"):
		objects.append_array(workshop_objects)
	# shuffle the objects
	objects.shuffle()
	
	# loop over all remaining(!) locations
	for location in possibleLocations:
		# get the last object in the list and remove it, so it cannot be selected multiple times (compared to pick_random)
		# use pop_back, because this is slightly faster and does not have to change any index values
		var selectedObject = load(objects.pop_back())
		# add this random object at this location
		location.add_child(selectedObject.instantiate())
	
# loads the room variations and the doorway into the current trial
func _populateRooms(room1, room2, door) -> void:
	# first, get the lists of room variations and shuffle them randomly. Duplicate to prevent removing original rooms
	var livingrooms = ExperimentLogic.living_room_variations.duplicate()
	var workshops = ExperimentLogic.workshop_variations.duplicate()
	livingrooms.shuffle()
	workshops.shuffle()
	# this string is adapted in the conditions below so we get the correct color of the walls on it
	var doorway_name : String = "Doorway_"
	
	# rooms are strings, one of ["LivingRoom", "Workshop"], door ["Doorway", "NoDoorway"]
	# go through first and second room separately
	# use pick_random, so it is possible to get the same room variation for both rooms
	if room1 == "LivingRoom":
		# instantiate a random living room variation at the first room's position
		$TrialSetup/PositionRoom1.add_child(load(livingrooms.pick_random()).instantiate())
		doorway_name += "Liv"
	else:
		# instantiate a workshop
		$TrialSetup/PositionRoom1.add_child(load(workshops.pick_random()).instantiate())
		doorway_name += "Wor"
	# repeat for second room
	if room2 == "LivingRoom":
		# instantiate a random living room variation at the first room's position
		$TrialSetup/PositionRoom2.add_child(load(livingrooms.pick_random()).instantiate())
		doorway_name += "Liv"
	else:
		# instantiate a workshop
		$TrialSetup/PositionRoom2.add_child(load(workshops.pick_random()).instantiate())
		doorway_name += "Wor"
	# if a doorway should be present, create one
	if door == "Doorway":
			$TrialSetup/PositionDoorway.add_child(load("res://components/rooms/" + doorway_name +
													   ".tscn").instantiate())
	# else do nothing
	
	# next, add the buttons to the rooms
	var button_show_items = load("res://components/item-display/button_show_items.tscn")
	var response_buttons = load("res://components/item-display/response_buttons.tscn")
	var response_area = load("res://components/rooms/mat.tscn")
	# buttons to show in room 1
	$TrialSetup/PositionRoom1.get_child(0).get_node("ButtonLocation").add_child(button_show_items.instantiate())
	# response buttons in room 2
	$TrialSetup/PositionRoom2.get_child(0).get_node("ButtonLocation").add_child(response_buttons.instantiate())
	# also add the response area
	$TrialSetup/PositionRoom2.get_child(0).get_node("ButtonLocation").add_child(response_area.instantiate())
	# switch two objects in the second room, if this is the condition
	if objects_changed:
		# get the response buttons node and call the switch function in that script
		switched_locations = $TrialSetup/PositionRoom2.get_child(0).get_node("ButtonLocation").get_child(0).switch()


func _getTrialSaveData() -> Dictionary:
	# general trial data
	var saveData = {
		# general information
		"trial_number": trial_number,
		"trialtype": trialtype,
		"first_room": first_room,
		"doorway": doorway,
		"second_room": second_room,
		"objects_changed": objects_changed,
		"switched_locations" : switched_locations,
		# collected data
		"response_objects_have_changed": respone_objects_have_changed,
		"response_time": response_time,
		"confidence": confidence,
		"confidence_time": confidence_time,
		# error information
		"repetitions": repetition,
		"error_info": error_info
		}
	# loop over all locations to get the object information
	for location in $ObjectLayout.get_children():
		# if this location does not have an object
		if location.get_child_count() == 0:
			# add an  entry to the saveData dictionary
			saveData.merge({str(location.name) : "none"})
		else:
			# save the name of the object node, which corresponds to the name of the file
			# within the stimulus-objects folder
			saveData.merge({str(location.name) : location.get_child(0).name})
	# add the information for the exact room variation
	saveData.merge({"first_room_variant": $TrialSetup/PositionRoom1.get_child(0).name,
					"second_room_variant": $TrialSetup/PositionRoom2.get_child(0).name})
	return saveData

func _saveTrial() -> void:
	var currentTrialSaveData = _getTrialSaveData()
	# make JSON string (sort: false, full_precision: true)
	var currentTrialSaveDataJSON = JSON.stringify(currentTrialSaveData, "\t", false, true)
	var currentTrialSaveDataCSV : String = _CSVstringify(currentTrialSaveData)
	print(currentTrialSaveDataJSON)
	# actually save the data to the save file
	var file = FileAccess.open(ExperimentLogic.saveFile, FileAccess.READ_WRITE)
	# jump to end of file
	file.seek_end(-1)
	# write data to file
	file.store_line(currentTrialSaveDataCSV)
	# add a new line
	#file.store_line("\n")
	# (not necessary) close file
	file.close()

# convert the dictionary with the trial data to a single line that can be written into a csv file
func _CSVstringify(dat : Dictionary) -> String:
	# prepare empty string
	var csvString : String = ""
	
	# in the following order, get the value from the dictionary and add comma/new line
	csvString += str(dat["trial_number"]) + ","
	csvString += str(dat["trialtype"]) + ","
	csvString += str(dat["first_room"]) + ","
	csvString += str(dat["doorway"]) + ","
	csvString += str(dat["second_room"]) + ","
	csvString += str(dat["objects_changed"]) + ","
	csvString += str(dat["switched_locations"]) + ","
	csvString += str(dat["response_objects_have_changed"]) + ","
	csvString += str(dat["response_time"]) + ","
	csvString += str(dat["confidence"]) + ","
	csvString += str(dat["confidence_time"]) + ","
	csvString += str(dat["repetitions"]) + ","
	csvString += str(dat["error_info"]) + ","
	csvString += str(dat["Location1"]) + ","
	csvString += str(dat["Location2"]) + ","
	csvString += str(dat["Location3"]) + ","
	csvString += str(dat["Location4"]) + ","
	csvString += str(dat["Location5"]) + ","
	csvString += str(dat["Location6"]) + ","
	csvString += str(dat["Location7"]) + ","
	csvString += str(dat["first_room_variant"]) + ","
	csvString += str(dat["second_room_variant"]) + "\n"
	
	return csvString

# do all the stuff that is needed after the current trial ended and has been moved
func _endTrial(success : String = "") -> void:
	# stop and reset all timers for this trial, so they start fresh when the trial is repeated
	_stopAllTimers()
	# prepare the next trial by picking a random one
	ExperimentLogic.setNextTrial(ExperimentLogic.pickRandomTrial())
	# instantiate the objects for this next trial
	ExperimentLogic.getNextTrial()._populateTrial()
	# make this trial the current trial
	ExperimentLogic.getNextTrial().reparent(ExperimentLogic.get_node("Trials").get_node("CurrentTrial"))
	
	if success == "valid":
		# delete the nodes so they do not accidentally appear
		for node in self.get_children():
			node.queue_free()
	
	# now everything is done, so we can start the next trial by moving the player there
	ExperimentLogic.addPlayerToCurrentTrial()
	
func _stopAllTimers() -> void:
	if get_node_or_null("MovementTimer") != null:
		$MovementTimer.stop()
	if get_node_or_null("ResponseTimer") != null:
		$ResponseTimer.stop()
	if get_node_or_null("ConfidenceTimer") != null:
		$ConfidenceTimer.stop()
	
###################################################################################################

func _on_movement_timer_timeout() -> void:
	# find the response buttons and let them tell the display to open
	# (this is an artifact of the buttons being reponsible for the item display to open/close)
	$TrialSetup/PositionRoom2.get_child(0).get_node("ButtonLocation").get_child(0).presentObjectsAfterTimer()
	# make error trial if participant is not in response area (moved too slow between displays)
	# this is done so it is very improbable the player did not actually see the second display
	if not playerInResponseArea:
		get_tree().call_group("player", "giveFeedback", "TOO_SLOW_MOVE")
		await get_tree().create_timer(1).timeout
		errorTrial("playerNotInResponseArea")

func _on_response_timer_timeout() -> void:
	get_tree().call_group("player", "giveFeedback", "TOO_SLOW_RESPONSE")
	errorTrial("slowResponse")
	
func _on_confidence_timer_timeout() -> void:
	get_tree().call_group("player", "giveFeedback", "TOO_SLOW_RESPONSE")
	errorTrial("slowConfidence")
