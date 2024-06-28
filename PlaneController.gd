extends CharacterBody3D

var throttle = 0
var speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	var input_dir = Input.get_vector("RudderLeft", "RudderLeft", "ElevatorUp", "ElevatorDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_on_floor():
		velocity.y -= gravity * delta
	throttleControl()
	moveForwards()
	elevator()
	rudder()
	fly()

	#if direction:
		#velocity.z = direction.z * speed
		#velocity.x = direction.x * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func throttleControl():
	if Input.is_action_pressed("ThrottleUp") and throttle < 101:
		throttle += 1
	if Input.is_action_pressed("ThrottleDown") and throttle >= 1:
		throttle -= 1
	$PlayerCam/Control/ProgressBar.value = throttle

func elevator():
	if speed > 10:
		if Input.is_action_pressed("ElevatorUp"):
			self.rotation.x += 0.02
		if Input.is_action_pressed("ElevatorDown"):
			self.rotation.x -= 0.02

func rudder():
	if Input.is_action_pressed("RudderRight"):
		rotation.y += 0.02
	if Input.is_action_pressed("RudderLeft"):
		rotation.y -= 0.02

func moveForwards():
	if speed < throttle:
		speed += 0.05
	if speed > throttle:
		speed -= 0.08
	self.velocity = Vector3(velocity.x, velocity.y, speed)

func fly():
	if speed > 15:
		velocity.y = speed/5 * rotation.x * 5
