extends Node

var dead = false

var hp = 10
var hp_max = 10
var stamina = 20
var stamina_max = 20
var mana = 0
var mana_max = 2

var xp = 0
var level = 1

func _ready():
	get_tree().call_group("HUD", "update_health_bar_max", hp_max)
	get_tree().call_group("HUD", "update_mana_bar_max", mana_max)
	get_tree().call_group("HUD", "update_stamina_bar_max", stamina_max)

func _physics_process(delta):
	death_checker()

func death_checker():
	if hp <= 0:
		if dead == false:
			dead = true
			get_tree().call_group("Player", "die")

func reduce_hp(id, amount):
	if id == self.get_parent():
		hp -= amount
		get_tree().call_group("Player", "damage_effect")
		get_tree().call_group("HUD", "update_health_bar_value", -amount)
		print(hp)

func increase_hp(id, amount):
	if id == self.get_parent():
		hp += amount
		get_tree().call_group("HUD", "update_health_bar_value", amount)
		print(hp)

func reduce_mana(id, amount):
	if id == self.get_parent():
		mana -= amount
		get_tree().call_group("HUD", "update_mana_bar_value", -amount)
		print(mana)
		
func increase_mana(id, amount):
	if id == self.get_parent():
		mana += amount
		get_tree().call_group("HUD", "update_mana_bar_value", amount)
		print(mana)

func reduce_stamina(id, amount):
	if id == self.get_parent():
		stamina -= amount
		get_tree().call_group("HUD", "update_stamina_bar_value", -amount)
		#print(stamina)

func increase_stamina(id, amount):
	if id == self.get_parent():
		stamina += amount
		get_tree().call_group("HUD", "update_stamina_bar_value", amount)
		#print(stamina)
