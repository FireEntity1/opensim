extends CharacterBody3D

@export var MAX_SPEED := 80.0 #meters per second
@export var MIN_SPEED := 0
@export var acceleration := 15.5
@export var decceleration := 10.5
@export var current_speed := 50.0
var targetSpeed = 15
var gearDown = true

@export var yaw_speed := 45.0 #degrees per second
@export var pitch_speed := 15.0
@export var roll_speed := 20.0

# @onready var prop = $Plane2/Plane/propellor
@onready var plane_mesh = $Plane

var turn_input =  Vector2()

func _ready() -> void:
	pitch_speed = deg_to_rad(pitch_speed)
	yaw_speed = deg_to_rad(yaw_speed)
	roll_speed = deg_to_rad(roll_speed)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ThrottleDown"):
		targetSpeed -= 0.3
	elif Input.is_action_pressed("ThrottleUp"):
		targetSpeed += 0.3
		
	if current_speed <= targetSpeed:
		current_speed += 0.2
	elif current_speed >= targetSpeed:
		current_speed -= 0.2
	$Rotation/PlayerCam/Control/ProgressBar.value = targetSpeed
	gear()
	var input = Input.get_vector("left","right","down","up")
	var roll = Input.get_axis("roll_left","roll_right")
	if input.y > 0 and current_speed < MAX_SPEED:
		current_speed += acceleration * delta
	elif input.y < 0 and current_speed > MIN_SPEED:
		current_speed -= decceleration * delta
	velocity = -basis.z * current_speed
	move_and_slide()
	var turn_dir = Vector3(-turn_input.y,-turn_input.x,-roll)
	apply_rotation(turn_dir,delta)
	if current_speed < 15:
		self.position.y = self.position.y
	self.rotation.z = clamp(self.rotation.z, -30, 30)
	turn_input = Vector2()
	camera()


func apply_rotation(vector,delta):
	rotate(basis.z,vector.z * roll_speed * delta)
	rotate(basis.x,vector.x * pitch_speed * delta)
	rotate(basis.y,vector.y * yaw_speed * delta)
	if vector.y < 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, deg_to_rad(-45)*-vector.y,delta/2)
	elif vector.y > 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, deg_to_rad(45)*vector.y,delta/2)
	else:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, 0,delta/2)

#func spin_propellor(delta):
	#var m = current_speed/MAX_SPEED
	#prop.rotate_z(150*delta*m)
	#if prop.rotation.z > TAU:
		#prop.rotation.z = 0

func camera():
	if Input.is_action_pressed("ui_left"):
		$Rotation.rotation.y -= 0.06
	if Input.is_action_pressed("ui_right"):
		$Rotation.rotation.y += 0.06
	if Input.is_action_pressed("ui_up"):
		$Rotation.rotation.x -= 0.06
	if Input.is_action_pressed("ui_down"):
		$Rotation.rotation.x += 0.06

func gear():
	if gearDown == true:
		$Plane/gear.show()
	elif gearDown == false:
		$Plane/gear.hide()
	if Input.is_action_just_pressed("gear") and gearDown == true:
		gearDown = false
	elif Input.is_action_just_pressed("gear") and gearDown == false:
		gearDown = true

func _on_control_analog_input(analog):
	turn_input = analog
