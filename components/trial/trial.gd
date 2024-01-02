extends Node

# general information for this trial
var first_room : String = ""
var doorway : String = ""
var second_room : String = ""
var trial_number : int = 0
var number_of_objects : int = 0
var object_contexts : Array = []

# data collected for this trial
var correctly_answered : bool = false #TODO
var response_time : float = 0 #TODO
var confidence : int = 0 #TODO
var confidence_time : float = 0 #TODO

# count additional presentations due to errors (not wrong answers!)
var repetition : int = 0
var error_info : String = ""

###################################################################################################

func _ready() -> void:
	# get max timer values in case they have changed
	$MovementTimer.wait_time = ExperimentLogic.MAX_MOVEMENT_TIME
	$ResponseTimer.wait_time = ExperimentLogic.MAX_RESPONSE_TIME
	$ConfidenceTimer.wait_time = ExperimentLogic.MAX_CONFIDENCE_TIME
	
# this is called to set all necessary information for the current trial
func set_conditions(c_room_1, c_doorway, c_room_2, c_number_of_objects, c_object_contexts) -> void:
	# assign the values to the variables from above
	first_room = c_room_1
	doorway = c_doorway
	second_room = c_room_2
	number_of_objects = c_number_of_objects
	object_contexts = c_object_contexts
	
# this should only be called for the current/next trial, since this instantiates all objects, rooms
# and decoration objects within the rooms
func populateTrial() -> void:
	# draw random objects
	_populateObjectLayout(number_of_objects, object_contexts)
	# draw room variations
	_populateRooms(first_room, second_room, doorway)
	
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
	
	# rooms are strings, one of ["LivingRoom", "Workshop"], door ["Doorway", "NoDoorway"]
	# go through first and second room separately
	# use pick_random, so it is possible to get the same room variation for both rooms
	if room1 == "LivingRoom":
		# instantiate a random living room variation at the first room's position
		$TrialSetup/PositionRoom1.add_child(load(livingrooms.pick_random()).instantiate())
	else:
		# instantiate a workshop
		$TrialSetup/PositionRoom1.add_child(load(workshops.pick_random()).instantiate())
	# repeat for second room
	if room2 == "LivingRoom":
		# instantiate a random living room variation at the first room's position
		$TrialSetup/PositionRoom2.add_child(load(livingrooms.pick_random()).instantiate())
	else:
		# instantiate a workshop
		$TrialSetup/PositionRoom2.add_child(load(workshops.pick_random()).instantiate())
	# if a doorway should be present, create one
	if door == "Doorway":
			$TrialSetup/PositionDoorway.add_child(load("res://components/rooms/Doorway.tscn").instantiate())
	# else do nothing

func getTrialSaveData() -> Dictionary:
	# general trial data
	var saveData = {
		# general information
		"trial_number": trial_number,
		"first_room": first_room,
		"doorway": doorway,
		"second_room": second_room,
		# collected data
		"correctly_answered": correctly_answered,
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
