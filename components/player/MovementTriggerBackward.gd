@tool
extends XRToolsMovementProvider

## Movement provider order
@export var order : int = 10

## Movement speed
@export var max_speed : float = 3.0

## Input action for movement direction
@export var input_action : String = "trigger"

# Controller node
@onready var _controller := XRHelpers.get_xr_controller(self)

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementDirect" or super(name)
	
func physics_movement(_delta: float, player_body: XRToolsPlayerBody, _disabled: bool):
	# Skip if the controller isn't active
	if !_controller.get_is_active():
		return
		
	# get trigger strength, corrected for dead zone
	var dz_input_action = _controller.get_float(input_action)
	
	player_body.ground_control_velocity.y -= dz_input_action * max_speed
	
	# Clamp ground control
	var length := player_body.ground_control_velocity.length()
	if length > max_speed:
		player_body.ground_control_velocity *= max_speed / length
	
	
# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Check the controller node
	if !XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")

	# Return warnings
	return warnings


## Find the left [XRToolsMovementDirect] node.
##
## This function searches from the specified node for the left controller
## [XRToolsMovementDirect] assuming the node is a sibling of the [XROrigin3D].
static func find_left(node : Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_left_controller(node),
		"*",
		"XRToolsMovementDirect") as XRToolsMovementDirect


## Find the right [XRToolsMovementDirect] node.
##
## This function searches from the specified node for the right controller
## [XRToolsMovementDirect] assuming the node is a sibling of the [XROrigin3D].
static func find_right(node : Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_right_controller(node),
		"*",
		"XRToolsMovementDirect") as XRToolsMovementDirect
