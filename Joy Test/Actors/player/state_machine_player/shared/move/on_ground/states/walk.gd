extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"

#Walk Variables
var accel = 16
var deaccel = 16

var walk_speed_thresh_lower = 0.1


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(event):
#	if Input.is_action_just_pressed("jump"):
#		emit_signal("state_switch", "jump")
	pass


#Acts as the _process method would
func update(delta):
	velocity = calc_walk_velocity(velocity, delta)
	
	.update(delta)
	
	if velocity.length() < walk_speed_thresh_lower and get_joystick_input_l().length() == 0.0:
		emit_signal("state_switch", "idle")
		return
	
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump")
		return


func _on_animation_finished(_anim_name):
	return


###WALK FUNCTIONS###
func calc_walk_velocity(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	input = get_joystick_input_l()
	
	#Get direction
	input_direction = input.normalized().rotated(-camera_angles.y)
	
	velocity = interp_walk_velocity(input_direction, current_velocity, delta)
	
	if input.length() > 0:
		rotate_to_direction(input_direction)
	
	return(velocity)


func interp_walk_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var target_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	temp_vel.x = current_velocity.x
	temp_vel.z = current_velocity.z
	
	target_vel.x = input_direction.x * speed_full
	target_vel.z = input_direction.y * speed_full
	
	#Get correct acceleration to use
	var acceleration
	if input_direction.length() > 0:
		acceleration = accel
	else:
		acceleration = deaccel
	
	new_vel = temp_vel.linear_interpolate(target_vel, acceleration * delta)
	
	#Check new velocity
	if new_vel.length() < walk_speed_thresh_lower:
		new_vel = Vector3(0,0,0)
	
	
	return new_vel


func rotate_to_direction(direction): #Direction should be normalized
	var angle = rad2deg(Vector2(0, 1).angle_to(-direction)) #calc degree of player rotation on y axis
	
	var rot_final = Body.get_rotation_degrees()
	rot_final.y = -angle
	
	Body.set_rotation_degrees(rot_final)



