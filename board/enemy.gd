extends Node2D

var curr_health

func _input_event(viewport, event, shape_idx):
	# This function is automatically called when you click a node with a CollisionShape2D
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var board = get_parent()
			if board and board.has_method("clicked_boss"):
				board.clicked_boss(self)
