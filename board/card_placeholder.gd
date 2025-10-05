extends Node2D

var strength

var enemy: bool
var place
var is_occupied = false
var have_weapon = false

var weapon_stats = 0
var max_stats = 5
var stats = 0

func _ready():
	$Minion.visible = false
	$value.visible = false
	$Arsenal.visible = false


func _input_event(viewport, event, shape_idx):
	# This function is automatically called when you click a node with a CollisionShape2D
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var board = get_parent().get_parent()
			if board and board.has_method("clicked_placeholder"):
				board.clicked_placeholder(self)

func set_stats(st):
	stats = st
	max_stats = st
	$value.text = str(stats)
	$value.visible = true

func deal_dmg(dmg):
	stats = stats - dmg
	if stats <= 0:
		$Minion.visible = false
		$Arsenal.visible = false
		is_occupied = false
		have_weapon = false

func healing(heal):
	stats = stats + heal
	if stats > max_stats:
		stats = max_stats
