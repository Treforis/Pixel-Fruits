extends CharacterBody2D

var target = GameData.player_ref
var health = 100
const SPEED = 100

func _ready() -> void:
	target = GameData.player_ref

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var direction = (target.position - position).normalized()
	velocity = direction * SPEED
	move_and_slide()

func take_damage(attack: AttackData) -> void:
	health -= attack.damage
	print("Hit by:", attack.attack_type, "| Damage:", attack.damage)

	match attack.fruit_type:
		"Rubber":
			print("Rubber-type effect triggered")

	match attack.effect:
		"stretch":
			# Knockback logic here
			pass
		"multi_hit":
			# Flinch resistance, animation, etc.
			pass

	if health <= 0:
		die()

func die():
	queue_free()  # Or play a death animation first
