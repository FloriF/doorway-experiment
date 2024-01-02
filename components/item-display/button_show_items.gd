extends Node3D

# this defines that an item display will be created
# preload makes sure the item display is already in memory
var connectedItemDisplay := preload("res://components/item-display/item_display.tscn").instantiate()

# as soon as the button is spawned, create the corresponding item display
func _ready() -> void:
	# delete the preview display
	$ItemDisplayLocation/InEditorPreviewItemDisplay.queue_free()
	# instantiate the item display
	$ItemDisplayLocation.add_child(connectedItemDisplay)

	
	
	
# when the button is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	# if the button is allowed to activate (the timeout timer is not running)
	if $ButtonTimeOut.is_stopped():
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
		# start the timer
		$ButtonTimeOut.start()
	else:
		print("Button pressed but nothing should happen")
