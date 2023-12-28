extends Node3D

# this defines that an item display will be created
# preload makes sure the item display is already in memory
var connectedItemDisplay := preload("res://components/item-display/item_display.tscn").instantiate()

# as soon as the button is spawned, create the corresponding item display
func _ready() -> void:
	$ItemDisplayLocation/InEditorPreviewItemDisplay.visible = false
	$ItemDisplayLocation.add_child(connectedItemDisplay)
	
# when the button is pressed
func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	# if the button is allowed to activate (the timeout timer is not running)
	if $ButtonTimeOut.is_stopped():
		# show the objects of the corresponding item display
		$ItemDisplayLocation.get_node("ItemDisplay").present_objects()
		# start the timer
		$ButtonTimeOut.start()
	else:
		print("Button pressed but nothiung should happen")
