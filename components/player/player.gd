extends Node3D

var xr_interface: XRInterface

func _ready() -> void:
	# default code to make XR work
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")

		# Turn off v-sync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")


func fadeToBlack() -> void:
	$XROrigin3D/XRCamera3D/FadeAnimation.play("fade_to_black")
	
func fadeToScene() -> void:
	$XROrigin3D/XRCamera3D/FadeAnimation.play_backwards("fade_to_black")

func _on_xr_controller_left_button_pressed(name: String) -> void:
	if name == "ax_button":
		toggle_vignette_visibility()
		
# experimenter triggers the calibrate height function of the xr toolbox
func expCalibrateHeight() -> void:
	# set the flag to true, so the next time the player is moved in any way, the calibration is triggered
	# see xr toolbox documentation on PlayerBody, player_calibrate_height 
	$XROrigin3D/PlayerBody.player_calibrate_height = true
		
func toggle_vignette_visibility() -> void:
	# set visibility
	$XROrigin3D/XRCamera3D/Vignette.visible = not $XROrigin3D/XRCamera3D/Vignette.visible
	# update toggle button
	get_tree().call_group("vignetteToggle", "set_pressed_no_signal", $XROrigin3D/XRCamera3D/Vignette.visible)
	
# toggle trackpad/joystick movement option
func toggle_trackpad(new_state: bool) -> void:
	$XROrigin3D/XRControllerRight/MovementDirectJoystick.enabled = new_state
	
# toggle trigger movement option
func toggle_triggers(new_state: bool) -> void:
	$XROrigin3D/XRControllerLeft/MovementTriggerBackward.enabled = new_state
	$XROrigin3D/XRControllerRight/MovementTriggerForward.enabled = new_state
