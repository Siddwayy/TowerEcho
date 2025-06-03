# DestructionEffect.gd
extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D # Get the GPUParticles2D node

func _ready():
	# Start emitting particles immediately when this effect scene is created.
	# Since 'One Shot' is true, it will emit all particles once.
	particles.emitting = true

	# This effect scene should remove itself after the particles are done.
	# We'll use a Timer for this.
	var timer = Timer.new()
	# Wait for the particle lifetime plus a small buffer to ensure all are faded.
	# particles.lifetime is the duration each particle lives.
	timer.wait_time = particles.lifetime + 0.5
	timer.one_shot = true # Timer runs once
	# When the timer finishes, call this scene's 'queue_free' method to remove it.
	timer.connect("timeout", Callable(self, "queue_free"))
	add_child(timer) # Add timer to the scene tree so it can run
	timer.start()    # Start the timer
