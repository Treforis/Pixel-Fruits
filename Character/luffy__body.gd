extends CharacterBody2D

# --- NODES ---
@onready var animated_sprite = $AnimatedSprite2D
@onready var punch_timer = $Punchtimer
@onready var punch_hitbox = $PunchHitbox
@onready var punch_shape = $PunchHitbox/CollisionShape2D
@onready var body_hitbox = $CollisionShape2D
@onready var attack_cooldown_timer = $ABTimer1
@onready var ability_timer_2 = $ABTimer2
@onready var sword = $Sword
@onready var animation_player = $AnimationPlayer

# --- PLAYER STATE ---
var current_fruit_name = ""
var current_fruit_type = ""
var current_fruit_effect = ""
var current_fruit_description = ""

var current_weapon_name = ""
var current_weapon_type = ""
var current_weapon_description = ""

var current_item_slot = "1"
var current_attack_data : AttackData

# --- CONSTANTS & VARIABLES ---
const SPEED = 300.0
var punch_offset := Vector2(30, 0)

# --- INIT ---
func _ready():
	punch_hitbox.monitoring = false
	punch_hitbox.visible = false
	GameData.player_ref = self

# --- MAIN LOOP ---
func _physics_process(delta: float) -> void:
	# Movement Input
	var direction_x := Input.get_axis("left", "right")
	var direction_y := Input.get_axis("up", "down")

	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Input Handling
	item_slot()
	sword_activation()

	# Attack Handling
	if current_fruit_name == "Rubber Fruit" and current_item_slot == "1":
		use_rubber_moves()
	elif Input.is_action_just_pressed("punch") and punch_timer.is_stopped():
		normal_punch()

	# Animation State
	if punch_timer.is_stopped():
		punch_shape.disabled = true
		punch_hitbox.position = Vector2(0, 0)

		if velocity.x != 0 or velocity.y != 0:
			animated_sprite.play("Running")
			animated_sprite.flip_h = velocity.x > 0
		else:
			animated_sprite.play("Idle")

	move_and_slide()

# --- ITEM PICKUP LOGIC ---
func pick_up_item(item):
	if item.item_type == "fruit":
		current_fruit_name = item.item_name
		current_fruit_type = item.item_type
		current_fruit_effect = item.effect_type
		current_fruit_description = item.description

		GameData.current_fruit_name = item.item_name
		GameData.current_fruit_type = item.item_type
		GameData.current_fruit_effect = item.effect_type
		GameData.current_fruit_description = item.description

		print("Picked up: ", GameData.current_fruit_name)

	elif item.item_type == "weapon":
		current_weapon_name = item.item_name
		current_weapon_type = item.item_type
		current_weapon_description = item.description

		GameData.current_weapon_name = item.item_name
		GameData.current_weapon_type = item.item_type
		GameData.current_weapon_description = item.description

		print("Picked up: ", GameData.current_weapon_name)

# --- BASIC ATTACK ---
func normal_punch():
	animated_sprite.play("Punch")
	punch_timer.start(1)
	punch_shape.disabled = false

	current_attack_data = AttackData.new()
	current_attack_data.source = self
	current_attack_data.attack_type = "Normal Punch"
	current_attack_data.fruit_type = ""
	current_attack_data.damage = 10
	current_attack_data.effect = ""

	update_punch_position()

# --- RUBBER FRUIT ATTACKS ---
func rubber_punch():
	animated_sprite.play("RPunch")
	punch_timer.start(1.5)
	punch_offset = Vector2(50, 0)
	punch_shape.disabled = false

	current_attack_data = AttackData.new()
	current_attack_data.source = self
	current_attack_data.attack_type = "Rubber Punch"
	current_attack_data.fruit_type = "Rubber"
	current_attack_data.damage = 25
	current_attack_data.effect = "stretch"

	update_punch_position()

func rubber_gattling_punch() -> void:
	animated_sprite.play("GPunch")
	punch_timer.start(2)
	punch_shape.disabled = false
	attack_cooldown_timer.start()

	current_attack_data = AttackData.new()
	current_attack_data.source = self
	current_attack_data.attack_type = "Rubber Gattling"
	current_attack_data.fruit_type = "Rubber"
	current_attack_data.damage = 8
	current_attack_data.effect = "multi_hit"

	await async_gattling_punch()

#punching system to simulate multiple punches
func async_gattling_punch() -> void:
	for i in range(7):
		var flip = animated_sprite.flip_h
		var offset = punch_offset
		if flip:
			offset = -punch_offset

		punch_hitbox.position = -offset
		punch_hitbox.monitoring = true
		punch_hitbox.visible = true
		#brings the offset in and out to simulate different hits
		await get_tree().create_timer(0.1).timeout

		punch_hitbox.position = Vector2(0, 0)
		await get_tree().create_timer(0.1).timeout

	punch_hitbox.monitoring = false
	punch_hitbox.visible = false

# --- PUNCH POSITIONING ---
func update_punch_position():
	var flip = animated_sprite.flip_h
	var offset = punch_offset
	if flip:
		offset = -punch_offset

	punch_hitbox.position = -offset
	punch_hitbox.monitoring = true
	punch_hitbox.visible = true

# --- RUBBER MOVE INPUT HANDLING ---
func use_rubber_moves():
	if Input.is_action_just_pressed("punch") and punch_timer.is_stopped():
		rubber_punch()
	elif Input.is_action_just_pressed("gpunch") and punch_timer.is_stopped() and attack_cooldown_timer.is_stopped():
		rubber_gattling_punch()

# --- ITEM SLOT SWITCHING ---
func item_slot():
	if Input.is_action_just_pressed("item_slot_1"):
		current_item_slot = "1"
		print(current_item_slot)
	elif Input.is_action_just_pressed("item_slot_2"):
		current_item_slot = "2"
		print(current_item_slot)

# --- SWORD VISIBILITY BASED ON SLOT ---
func sword_activation():
	if is_instance_valid(sword):
		if current_weapon_name == "Sword" and current_item_slot != "1":
			sword.visible = true
		else:
			sword.visible = false
