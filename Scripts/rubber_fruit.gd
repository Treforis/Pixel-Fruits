extends Area2D
@export var item_name: String = "Rubber Fruit"
@export var item_type: String = "fruit"
@export var effect_type: String = "rubber"
@export var description: String = "Grants rubber powers!"


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body == GameData.player_ref and body.has_method("pick_up_item"):
		body.pick_up_item(self)
		queue_free()
