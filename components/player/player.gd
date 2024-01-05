extends Node3D

var teleport_transform

# initialize XR/VR
var xr_interface: XRInterface

###################################################################################################

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
	$XRCamera3D/FadeAnimation.play("fade_to_black")
	# give the player some time in the dark, during which the next trial will be prepared
	$XRCamera3D/Timer.start()
	
func fadeToScene() -> void:
	$XRCamera3D/FadeAnimation.play_backwards("fade_to_black")

# experimenter triggers the calibrate height function of the xr toolbox
func expCalibrateHeight() -> void:
	# set the flag to true, so the next time the player is moved in any way, the calibration is triggered
	# see xr toolbox documentation on PlayerBody, player_calibrate_height 
	$PlayerBody.player_calibrate_height = true

func toggle_vignette_visibility() -> void:
	# set visibility
	$XRCamera3D/Vignette.visible = not $XRCamera3D/Vignette.visible
	# update toggle button
	get_tree().call_group("vignetteToggle", "set_pressed_no_signal", $XRCamera3D/Vignette.visible)
	
# toggle trackpad/joystick movement option
func toggle_trackpad(new_state: bool) -> void:
	$XRControllerRight/MovementDirectJoystick.enabled = new_state
	
# toggle trigger movement option
func toggle_triggers(new_state: bool) -> void:
	$XRControllerLeft/MovementTriggerBackward.enabled = new_state
	$XRControllerRight/MovementTriggerForward.enabled = new_state

# call the teleport function of the xr tools player body
# NOTE the actual teleportation happens on the timer timeout!
func initiate_teleport(target_transform) -> void:
	# fade to black
	$XRCamera3D/FadeAnimation.play("fade2black")
	# start timer so fade animation finishes before player is teleported
	$XRCamera3D/TeleportTimer.start()
	# set teleport location
	teleport_transform = target_transform

###################################################################################################

func _on_xr_controller_left_button_pressed(name: String) -> void:
	if name == "ax_button":
		toggle_vignette_visibility()
		
func _on_teleport_timer_timeout() -> void:
	# teleport the player
	$PlayerBody.teleport(teleport_transform)
	# fade back to scene
	$XRCamera3D/FadeAnimation.play_backwards("fade2black")
