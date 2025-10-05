extends Area2D


enum CardType { MIXTURE_DMG, MIXTURE_HEAL, MIXTURE_DRAW, MINION, ARSENAL }

var chosen = true
var value = 0
var card_type

func _ready():
	$Line2D.visible = false
	$Line2D2.visible = false
	$value.text = str(value)

func _input_event(viewport, event, shape_idx):
	# This function is automatically called when you click a node with a CollisionShape2D
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if chosen:
				chosen = false
				$Line2D.visible = true
				$Line2D2.visible = true
				print("clicked")
			else:
				chosen = true
				$Line2D.visible = false
				$Line2D2.visible = false
