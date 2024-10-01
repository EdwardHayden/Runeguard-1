extends KinematicBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const FRICTION = 600

var mouse_in = false
var dmg = 0
var stm_cost = 0
var knight_selectable = false

var velocity = Vector2.ZERO
var direction_vector = Vector2.ZERO
var previous_position = Vector2.ZERO

var hp = 6
var max_hp = 6

var stamina = 10
var max_stamina = 10

var move_speed = 10
var move_distance = 0

var dead = false

var rng = RandomNumberGenerator.new()

enum{IDLE, MOVE}
var state = IDLE

onready var character_animations = $NPCAnimations
onready var animation_player = $AnimationPlayer
onready var blood_effect = $BloodEffect
onready var slash_effect2 = $SlashEffect
onready var collision_shape_2d = $CollisionShape2D
onready var navigation_2d = get_node("../../Navigation2D")
onready var player = get_node("../Player")
onready var melee_area = $MeleeArea

func _ready():
	rng.randomize()
	$Health.max_value = hp

func _physics_process(delta):
	match state:
		IDLE:
			change_direction(self.global_position)
		MOVE:
			if melee_area.get_overlapping_bodies().find(player) == -1:
				var new_path = navigation_2d.get_simple_path(self.global_position, player.global_position)
				new_move_along_path(new_path, delta)
			else:
				if stamina >= 5:
					get_tree().call_group("PlayerInfo", "reduce_hp",player ,2)
				stamina = 0
			if stamina <= 0:
				get_tree().call_group("Player", "enemy_end_turn")
				stamina = max_stamina
				state = IDLE
		

func new_move_along_path(path, delta):
	previous_position = self.global_position
	velocity = self.global_position
	velocity = velocity.move_toward(path[1], ACCELERATION*delta)
	velocity = self.global_position.direction_to(velocity)*MAX_SPEED
	move_and_slide(velocity)
	change_direction(previous_position)
	move_distance = pow(pow((self.global_position - previous_position).x, 2)+pow((self.global_position - previous_position).y, 2), 0.5)
	stamina = stamina - (move_distance/10)
	print(move_distance)
	if round(move_distance*10) <= 1:
		stamina = 0
	
func change_direction(last_pos):
	direction_vector = self.global_position-last_pos
	direction_vector = direction_vector.normalized()
	if direction_vector != Vector2.ZERO:
		if direction_vector.y > 0:
			if direction_vector.x > 0.5:
				character_animations.set_animation("WalkRight")
			elif direction_vector.x < -0.5:
				character_animations.set_animation("WalkLeft")
			else:
				character_animations.set_animation("WalkDown")
		elif direction_vector.y < 0:
			if direction_vector.x > 0.5:
				character_animations.set_animation("WalkRight")
			elif direction_vector.x < -0.5:
				character_animations.set_animation("WalkLeft")
			else:
				character_animations.set_animation("WalkUp")
		else:
			if direction_vector.x > 0:
				character_animations.set_animation("WalkRight")
			elif direction_vector.x < 0:
				character_animations.set_animation("WalkLeft")
	else: 
		if character_animations.get_animation() == "WalkRight":
			character_animations.set_animation("IdleRight")
		elif character_animations.get_animation() == "WalkLeft":
			character_animations.set_animation("IdleLeft")
		elif character_animations.get_animation() == "WalkUp":
			character_animations.set_animation("IdleUp")
		elif character_animations.get_animation() == "WalkDown":
			character_animations.set_animation("IdleDown")

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

func death_checker():
	if hp <= 0:
		if dead == false:
			dead = true
			get_tree().call_group("Player", "enemy_death", self)
			self.queue_free()
	
func reduce_hp(id, amount):
	if id == self:
		damage_effect()
		hp -= amount
		$Health.value = hp
		death_checker()
		print(hp)

func increase_hp(id, amount):
	if id == self:
		hp += amount
		print(hp)

func check_target_sight(id, target_id, obstructions):
	if id == self:
		obstructions.append(target_id)
		var space_state = get_world_2d().direct_space_state
		var target_height = target_id.get_node("CollisionShape").shape.height -1
		var left = target_id.global_position + Vector2(target_height, 0)
		var right = target_id.global_position + Vector2(-target_height, 0)
		for pos in [left, right]:
			var result = space_state.intersect_ray(self.global_position, pos, obstructions)
			if result:
				self.visible = false
				get_tree().call_group("Player", "enemy_response", self, false)
			else:
				self.visible = true
				get_tree().call_group("Player", "enemy_response", self, true)
				break

func activate_turn(id):
	if id == str(self):
		move_distance = 0
		state = MOVE

func unselectable(id):
	if id == self:
		self.modulate = Color(1, 1, 1, 1)
		knight_selectable = false

func selectable(id, damage, stamina_cost):
	if id == self:
		self.modulate = Color(1, 1.5, 1, 1)
		dmg = damage
		stm_cost = stamina_cost
		knight_selectable = true

func _on_ClickableArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		if knight_selectable == true:
			reduce_hp(self, dmg)
			get_tree().call_group("HUD", "finish_selection")
			get_tree().call_group("PlayerInfo", "reduce_stamina", player, stm_cost)
