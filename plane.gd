extends CharacterBody3D

@export var MAX_SPEED := 80.0 #meters per second
@export var MIN_SPEED := 0
@export var acceleration := 15.5
@export var decceleration := 10.5
@export var current_speed := 50.0
var targetSpeed = 0

@export var yaw_speed := 45.0 #degrees per second
@export var pitch_speed := 45.0
@export var roll_speed := 45.0

# @onready var prop = $Plane2/Plane/propellor
@onready var plane_mesh = $PlaneMesh

var turn_input =  Vector2()

func _ready() -> void:
	pitch_speed = deg_to_rad(pitch_speed)
	yaw_speed = deg_to_rad(yaw_speed)
	roll_speed = deg_to_rad(roll_speed)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ElevatorUp"):
		targetSpeed -= 0.3
	elif Input.is_action_pressed("ElevatorDown"):
		targetSpeed += 0.3
		
	if current_speed <= targetSpeed:
		current_speed += 0.2
	elif current_speed >= targetSpeed:
		current_speed -= 0.2
	$PlayerCam/Control/ProgressBar.value = targetSpeed
	
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
	self.rotation.z = clamp(self.rotation.z, -45, 45)
	turn_input = Vector2()
	# spin_propellor(delta)


func apply_rotation(vector,delta):
	rotate(basis.z,vector.z * roll_speed * delta)
	rotate(basis.x,vector.x * pitch_speed * delta)
	rotate(basis.y,vector.y * yaw_speed * delta)
	#lean mesh
	if vector.y < 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, deg_to_rad(-45)*-vector.y,delta)
	elif vector.y > 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, deg_to_rad(45)*vector.y,delta)
	else:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z, 0,delta)

#func spin_propellor(delta):
	#var m = current_speed/MAX_SPEED
	#prop.rotate_z(150*delta*m)
	#if prop.rotation.z > TAU:
		#prop.rotation.z = 0

#func _on_mouse_analog_input_analog_input(analog: Vector2) -> void:
	#pass


func _on_control_analog_input(analog):
	turn_input = analog
