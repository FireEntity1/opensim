extends CharacterBody3D

var throttle = 0
var speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	throttleControl()
	moveForwards()
	fly()

	move_and_slide()

func throttleControl():
	if Input.is_action_pressed("ThrottleUp") and throttle < 101:
		throttle += 1
	if Input.is_action_pressed("ThrottleDown") and throttle >= 1:
		throttle -= 1
	$PlayerCam/Control/ProgressBar.value = throttle

func moveForwards():
	if speed < throttle:
		speed += 0.05
	if speed > throttle:
		speed -= 0.08
	self.velocity = Vector3(velocity.x, velocity.y, speed)

func fly():
	if speed > 13:
		velocity.y = speed/5
