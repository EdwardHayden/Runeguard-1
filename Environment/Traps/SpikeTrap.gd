extends AnimatedSprite

func _on_ActivateArea_area_entered(area):
	get_tree().call_group("TrapLogic", "reduce_hp",area.get_parent() , 3)
	self.frame = 0
