extends Control



func _on_Exit_pressed():
	get_tree().quit()



func _on_StartGame_pressed():
	get_tree().change_scene("res://TutorialDungeon.tscn")
