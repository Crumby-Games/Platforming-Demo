extends CharacterBody2D

class_name Player

# The maximum sideways (horizontal) speed
# (how many pixels the player character moves per second)
const MOVE_SPEED = 200.0 

# The fixed upwards speed at the moment that the jump button is pressed.
const JUMP_SPEED = 315.0

# The speed of the little hop when getting down from a platform
const DROPDOWN_JUMP_SPEED = 50.0

# How much speed the player character gains per second when moving
const ACCELERATION = 1600.0 

# How much speed the player character loses per second when not moving
const DECELERATION = 2000.0

# The direction that the player is moving. -1 is left, 1 is right. Can be a decimal if a controller is used
# This is referred to in multiple functions, so we define it up here.
var move_direction = 0.0

var locked_controls = false
var locked_animation = false

# Runs only once when this node (in this case, the player character) is loaded
# Functions that start with a '_' is used by Godot itself. Anything else is defined simply for the sake of code simplicity.
func _ready() -> void:
	pass # This just means "do nothing". It's useful when you haven't implemented a bit of code yet.

# Since there's no death animation at the moment, we just immediately restart the level
func die() -> void:
	$Visual/AnimatedSprite.play("die")
	velocity.y = -200
	locked_animation = true
	locked_controls = true
	collision_layer = 0
	collision_mask = 0
	await get_tree().create_timer(0.5).timeout
	World.restart_level()

# Runs exactly once per frame.
# If there's a lot to do in a single frame, then the frame takes longer to load, causing a visual stutter.
# Depending on the framerate of your monitor and lag, this will typically run around 60 times a second.
# It should be used for visual things (like animations or particle effects) which the 
# (Delta is the time (in seconds) since the last frame. It will change slightly every frame. It is prefixed by '_' to tell Godot that we're not using it at the moment)
func _process(_delta: float) -> void:
	# Flip the character based on whether moving left or right
	if move_direction != 0:
		$Visual.scale.x = sign(move_direction) # Turns something like -0.41 into -1 and 0.358 into 1
	
	if not locked_animation:
		# Run particles should not emit by default
		$Visual/RunParticles.emitting = false 
		
		if is_on_floor():
			# If character is not moving, play idle animation
			if move_direction == 0:
				$Visual/AnimatedSprite.play("idle")
			
			# If character is moving, play run animation and emit particles
			else:
				# Character is running
				$Visual/AnimatedSprite.play("run")
				$Visual/RunParticles.emitting = true
		else:
			if velocity.y < 0:
				$Visual/AnimatedSprite.play("jump")
			else:
				$Visual/AnimatedSprite.play("fall")
	
# Runs exactly 60 times a second REGARDLESS of framerate.
# This value can be changed in the project settings (Physics/Common: Physics Ticks per Second, if you're interested)
# This means, even when the game is lagging, physics is still performed properly even when not shown.
# Anything that affects the player character's physics directly should be done here.
# (Delta is the time (in seconds) since the last physics tick. It should always be the same)
func _physics_process(delta: float) -> void:
	# == CORE CONTROLLER == #

	# Add the gravity.
	# Only added while the player character is in the air in case of janky physics
	if not is_on_floor():
		velocity += get_gravity() * delta # Gravity can be changed in project settings
	
	if not locked_controls:
		# Handle jump.
		# Must only happen the moment the player character presses the jump button (space) and they must be on the floor.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = -JUMP_SPEED # Negative because upwards is in the negative Y direction
		
		# Get the input direction for movement.
		# -1 is left and 1 is right. Controller sticks can give you values between -1 and 1, but keyboard will always be -1, 0, or 1.
		move_direction = Input.get_axis("ui_left", "ui_right")
		
		# If on a platform, the player can drop down from it by pressing down. It is either true or false.
		dropping_down = Input.is_action_pressed("ui_down")
	else:
		move_direction = 0

	# If the player character is not trying to move, decelerate.
	if move_direction == 0:
		# Change velocity by the DECELERATION constant (either positive or negative) until the player character reaches 0 speed.
		# DECELERATION is multiplied by delta for the sake of frame consistency and physical accuracy (feel free to ask me why, but know that it is a rabbit hole)
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Otherwise, the player character must be trying to move, so accelerate in that direction.
	else:
		# Similar to deceleration, changes velocity by the ACCELERATION constant until the player character reaches their MOVE_SPEED.
		velocity.x = move_toward(velocity.x, move_direction * MOVE_SPEED, ACCELERATION * delta) 

	if dropping_down:
		dropdown_time += delta # (Keeps track of how long the player has been dropping down; don't worry about this)
		set_collision_mask_value(2, false) # Disable collision with platforms
	else:
		set_collision_mask_value(2, true) # Re-enable collision with platforms
		
	# == EXTRA BEHAVIOUR == #

	# (Add new movement abilities here, because they should be before move_and_slide())

	# == COLLISIONS == #
	# (although visual behaviour should typically lie in _process, sometimes it is worth implementing in _physics_process if it makes use of real-time physics or collision data)

	var velocity_before_collisions = velocity

	# Physically move the player character according to velocity, and calculate collisions.
	# Should always be done after velocity calculations for that physics tick.
	# Triggers collisions.
	move_and_slide()

	# If vertical (up-down) velocity after collisions is 0, check if 
	# Check for collisions by comparing velocity before and after calculating collisions
	if velocity.y == 0:
		# just hit the ground this frame because the character was moving down
		if velocity_before_collisions.y > 0:
			pass

		# just hit the ceiling this frame because the character was moving up
		elif velocity_before_collisions.y < 0:
			pass

# == UNDOCUMENTED CODE == #
# (Code that I make use of without taking the time to explain in comments. If you're interested, I could still walk you through it)

var dropdown_time = 0.0
const MIN_DROPDOWN_TIME = 0.1

# (A smart little system to ensure that dropping down lasts for at least a couple frames)
var dropping_down = false:
	set(value):
		if not value:
			if dropdown_time < MIN_DROPDOWN_TIME:
				return
			else:
				dropdown_time = 0.0
		dropping_down = value
