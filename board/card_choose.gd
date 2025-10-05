extends Area2D


var chosen = true

func _ready():
	$Line2D.visible = false
	$Line2D2.visible = false

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
