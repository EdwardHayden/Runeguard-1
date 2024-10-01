extends CanvasLayer

var hand = {
	"name":"Hand",
	"value":0,
	"damage":1,
	"stamina_cost":5
}

var sword = {
	"name":"Sword",
	"value":10,
	"damage":3,
	"stamina_cost":5
}

onready var hotbar1_content = sword
onready var hotbar2_content = hand
onready var hotbar3_content = hand
onready var hotbar4_content = hand
onready var hotbar5_content = hand
onready var hotbar6_content = hand
onready var hotbar7_content = hand
onready var hotbar8_content = hand
onready var hotbar9_content = hand
onready var hotbar10_content = hand

onready var health_bar = $Health
onready var mana_bar = $Mana
onready var stamina_bar = $Stamina
onready var player = get_parent()

func update_health_bar_max(amount):
	health_bar.max_value = amount

func update_health_bar_value(amount):
	health_bar.value = health_bar.value + amount

func update_mana_bar_max(amount):
	mana_bar.max_value = amount

func update_mana_bar_value(amount):
	mana_bar.value = mana_bar.value + amount

func update_stamina_bar_max(amount):
	stamina_bar.max_value = amount

func update_stamina_bar_value(amount):
	stamina_bar.value = stamina_bar.value + amount
	#print(stamina_bar.value)

func choose_target(item):
	player.taking_action = true
	for n in player.get_node("MeleeRange").get_overlapping_areas():
		get_tree().call_group("KnightEnemy", "selectable", n.get_parent(), item.damage, item.stamina_cost)
		

func finish_selection():
	player.taking_action = false
	for n in player.get_node("MeleeRange").get_overlapping_areas():
		get_tree().call_group("KnightEnemy", "unselectable", n.get_parent())

func _on_Hotbar1_pressed():
	if hotbar1_content.stamina_cost > player.get_node("PlayerInfo").stamina:
		pass
	else:
		choose_target(hotbar1_content)
	

func _on_Hotbar2_pressed():
	pass # Replace with function body.


func _on_Hotbar3_pressed():
	pass # Replace with function body.


func _on_Hotbar4_pressed():
	pass # Replace with function body.


func _on_Hotbar5_pressed():
	pass # Replace with function body.


func _on_Hotbar6_pressed():
	pass # Replace with function body.


func _on_Hotbar7_pressed():
	pass # Replace with function body.


func _on_Hotbar8_pressed():
	pass # Replace with function body.


func _on_Hotbar9_pressed():
	pass # Replace with function body.


func _on_Hotbar10_pressed():
	pass # Replace with function body.
