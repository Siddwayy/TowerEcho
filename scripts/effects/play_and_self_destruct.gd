# PlayAndSelfDestruct.gd (or similar name)
extends AudioStreamPlayer2D

func _ready():
	play() # Play the sound assigned in the Stream property
	connect("finished", Callable(self, "queue_free")) # Remove self when done
