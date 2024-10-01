extends KinematicBody2D

const ACCELERATION = 900
const MAX_SPEED = 100
const FRICTION = 600

var taking_action = false

var velocity = Vector2.ZERO
var direction_vector = Vector2.ZERO
var previous_position = Vector2.ZERO

var move_distance = 0
var initiative_list = ["player"]
var active_turn = ""
var combat_started = false
var enemies_on_screen = []
var turn_counter = 0
var new_list = []
var tempo = false
var id_to_remove 

var rng = RandomNumberGenerator.new()

onready var player_animations = $PlayerAnimations
onready var animation_player = $AnimationPlayer
onready var blood_effect = $BloodEffect
onready var slash_effect2 = $SlashEffect
onready var initiative_area = $InitiativeArea
onready var player_info = $PlayerInfo

enum{IDLE, MOVE, BATTLE}
var state = MOVE

func _ready():
	rng.randomize()

func _physics_process(delta):
	if len(initiative_list) > 1:
		if combat_started == false:
			combat_started = true
			state = BATTLE
			turn_counter = 0
			active_turn = "player"
	send_check_target_sight_signal()
	match state:
		IDLE:
			change_direction(self.global_position)
		MOVE:
			move(delta)
			
		BATTLE:
			battle(delta)

func send_check_target_sight_signal():
	if len(initiative_area.get_overlapping_areas()) != 0:
		var temp = []
		for x in initiative_area.get_overlapping_areas():
			temp.append(x.get_parent())
		enemies_on_screen = temp
		for x in initiative_area.get_overlapping_areas():
			get_tree().call_group("KnightEnemy", "check_target_sight",x.get_parent(), self, temp)

func move(delta):
	previous_position = self.global_position
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector*MAX_SPEED, ACCELERATION*delta)
		if taking_action == true:
			get_tree().call_group("HUD", "finish_selection")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
	velocity = move_and_slide(velocity)
	change_direction(previous_position)
	move_distance = pow(pow((self.global_position - previous_position).x, 2)+pow((self.global_position - previous_position).y, 2), 0.5)
	
func change_direction(last_pos):
	direction_vector = self.global_position-last_pos
	direction_vector = direction_vector.normalized()
	if direction_vector != Vector2.ZERO:
		if direction_vector.y > 0:
			if direction_vector.x > 0.5:
				player_animations.set_animation("WalkRight")
			elif direction_vector.x < -0.5:
				player_animations.set_animation("WalkLeft")
			else:
				player_animations.set_animation("WalkDown")
		elif direction_vector.y < 0:
			if direction_vector.x > 0.5:
				player_animations.set_animation("WalkRight")
			elif direction_vector.x < -0.5:
				player_animations.set_animation("WalkLeft")
			else:
				player_animations.set_animation("WalkUp")
		else:
			if direction_vector.x > 0:
				player_animations.set_animation("WalkRight")
			elif direction_vector.x < 0:
				player_animations.set_animation("WalkLeft")
	else: 
		if player_animations.get_animation() == "WalkRight":
			player_animations.set_animation("IdleRight")
		elif player_animations.get_animation() == "WalkLeft":
			player_animations.set_animation("IdleLeft")
		elif player_animations.get_animation() == "WalkUp":
			player_animations.set_animation("IdleUp")
		elif player_animations.get_animation() == "WalkDown":
			player_animations.set_animation("IdleDown")

func die():
	print("Dead")
	get_tree().change_scene("res://TutorialDungeon.tscn")

func damage_effect():
	var x = rng.randi_range(1, 5)
	if x == 1:
		blood_effect.animation = "BloodSplatter1"
	elif x == 2:
		blood_effect.animation = "BloodSplatter2"
	elif x == 3:
		blood_effect.animation = "BloodSplatter3"
	elif x == 4:
		blood_effect.animation = "BloodSplatter4"
	elif x == 5:
		blood_effect.animation = "BloodSplatter5"
	blood_effect.frame = 0
	slash_effect2.frame = 0
	animation_player.play("Hurt")

func _on_InitiativeArea_area_exited(area):
	var temp = []
	for x in initiative_area.get_overlapping_areas():
			temp.append(x.get_parent())
	get_tree().call_group("KnightEnemy", "check_target_sight",area.get_parent(), self, temp)


func _on_InitiativeArea_area_entered(area):
	#initiative_list.push_back(str(area.get_parent()))
	#if combat_started == false:
	#	cycle_initiative()
	#state = BATTLE
	#combat_started = true
	pass

func cycle_initiative():
	if tempo == true:
		print(id_to_remove + " is going to be removed")
		initiative_list.erase(id_to_remove)
		tempo == false
	print(initiative_list)
	if turn_counter >= len(initiative_list)-1:
		turn_counter = 0
	else:
		turn_counter += 1
	active_turn = initiative_list[turn_counter]
	if active_turn == "player":
		player_info.stamina = 0
		player_info.increase_stamina(self, player_info.stamina_max)
		move_distance = 0
	get_tree().call_group("KnightEnemy", "activate_turn", active_turn)
	print(active_turn)
	new_list = initiative_list

func battle(delta):
	player_info.reduce_stamina(self, move_distance/10)
	if len(initiative_list) <= 1:
		state = MOVE
		combat_started = false
		print("Battle Ended")
		player_info.stamina = 0
		player_info.increase_stamina(self, player_info.stamina_max)
	else:
		if active_turn == "player":
			if player_info.stamina > 0:
				move(delta)
			else:
				cycle_initiative()
				velocity = Vector2.ZERO
				change_direction(self.global_position)

func enemy_end_turn():
	cycle_initiative()

func enemy_death(id):
	id_to_remove = str(id)
	tempo = true

func enemy_response(id, tracking):
	if tracking == true:
		if initiative_list.find(str(id)) == -1:
			initiative_list.push_back(str(id))
	elif tracking == false:
		if initiative_list.find(str(id)) != -1:
			initiative_list.erase(str(id))
