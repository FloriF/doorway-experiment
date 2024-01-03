extends Node3D

# this defines that an item display will be created
# preload makes sure the item display is already in memory
var connectedItemDisplay := preload("res://components/item-display/item_display.tscn").instantiate()

# as soon as the button is spawned, create the corresponding item display
func _ready() -> void:
	# instantiate the item display
	$ItemDisplayLocation.add_child(connectedItemDisplay)
	# instantiate the objects from the current trial
	# (Next trial, since this function is called as soon as the button is spawned; and this happens
	# when the trial is being prepared and thus still in the next trial group)
	var objects = ExperimentLogic.getNextTrial().get_node("ObjectLayout").duplicate()
	# make the objects visible
	objects.visible = true
	# add the objects as child of the display, to get the corretc position
	$ItemDisplayLocation.get_child(0).add_child(objects)

# when the button is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	# if timeout timer is not already running (which means the button has not been pressed)
	if $ButtonTimeOut.is_stopped():
		# start the button timer to prevent multiple activations
		$ButtonTimeOut.start()
		# get the current trial information
		#var currentTrial = ExperimentLogic.getCurrentTrial()
		## instantiate the objects from the current trial
		## first, get the item display that was instantiated
		#var currentItemDisplay = $ItemDisplayLocation.get_child(0)
		## next, get the location where the objects should be shown
		#var objectLocation = currentItemDisplay.getObjectPositionOnDisplay
		#objectLocation.add_child(currentTrial)
		## make the objects visible
		#objectLocation.get_child(0).showObjects()
		# show the objects of the corresponding item display by lifting the lid
		$ItemDisplayLocation.get_node("ItemDisplay").present_objects()
		# start the trial's movement timer
		ExperimentLogic.getCurrentTrial().get_node("MovementTimer").start()

