extends Node3D

# as soon as the roof is spawned, make it visible
# this allows to make it invisible in the editor to see the interior
func _ready() -> void:
	$".".visible = true
