extends Node2D

var strength

var enemy: bool
var place
var is_occupied = false
var have_weapon = false

var weapon_stats
var max_stats = 5
var stats = 0
var card_sprite

func _ready():
	$Minion.visible = false
	$strenght_label.visible = false
	$Arsenal.visible = false


func _input_event(viewport, event, shape_idx):
	# This function is automatically called when you click a node with a CollisionShape2D
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var board = get_parent().get_parent()
			if board and board.has_method("clicked_placeholder"):
				board.clicked_placeholder(self)
				print("clicked")
