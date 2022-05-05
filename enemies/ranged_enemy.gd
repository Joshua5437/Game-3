extends Enemy
class_name RangedEnemy

export(PackedScene) var projectile


# Overrides Enemy's damage_target function to shoot at the target instead of melee damage
func damage_target():
	var new_projectile : Projectile = projectile.instance()
	new_projectile.setup(global_position, target.global_position, damage_amount)
	get_parent().add_child(new_projectile)
	attack_timer.start()
