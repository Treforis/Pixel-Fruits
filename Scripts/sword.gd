extends Area2D
@export var item_name: String = "Sword"
@export var item_type: String = "weapon"
@export var description: String = "Strong melee weapon"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body == GameData.player_ref and body.has_method("pick_up_item"):
			body.pick_up_item(self)
			queue_free()
	
