extends Node2D

var card_placeholder = preload("res://board/card_placeholder.tscn")
var card_choose = preload("res://board/card_choose.tscn")
var card_on_hand = preload("res://board/card_on_hand.tscn")

var turn = 1 # 1 = player, 0 = enemy

var max_number_of_turns = 6
var turns_left = 6
var board_width = 1152.0
var number_of_card_placeholders = 5
var x_difference_between_cards
var x_offset_troops = 100

var num_cards_to_choose = 5

var cards_on_hand := []
var cards_to_choose := []

var card_on_hand_and_chosen

enum CardType { MIXTURE_DMG, MIXTURE_HEAL, MIXTURE_DRAW, MINION, ARSENAL }
enum EnemyMove { MIXTURE_DMG, MIXTURE_HEAL, MINION, ARSENAL }

var hand_size = 7

func _ready():
	board_width = board_width - x_offset_troops*2
	x_difference_between_cards = board_width/number_of_card_placeholders
	add_enemy_cards_placeholders()
	add_player_cards_placeholders()
	turns_left = max_number_of_turns
	player_choose_cards()
	$number_of_turns_left.text = str(turns_left)


func player_choose_cards():
	$player_choose.visible = true
	$ColorRect.color = Color(0.0, 0.0, 0.0, 0.5)
	$ColorRect.visible = true
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var x_difference_between_cards_choose = board_width/num_cards_to_choose
	for i in range(num_cards_to_choose):
		var card_x = x_difference_between_cards_choose * i + x_difference_between_cards_choose/2
		var new_card_choose = card_choose.instantiate()
		new_card_choose.position = Vector2(card_x, 0)
		cards_to_choose.append(new_card_choose)
		$player_choose.add_child(new_card_choose)
	var btn = $player_choose/Button
	btn.position = Vector2(x_difference_between_cards_choose * 2 + x_difference_between_cards_choose/2, 100)
	
	
	
func add_enemy_cards_placeholders():
	for i in range(number_of_card_placeholders):
		var pos_x = x_difference_between_cards * i + x_difference_between_cards/2 + x_offset_troops
		var new_card_placeholder = card_placeholder.instantiate()
		new_card_placeholder.position = Vector2(pos_x, 0)
		new_card_placeholder.enemy = true
		new_card_placeholder.place = i
		$enemy_troops.add_child(new_card_placeholder)


func add_player_cards_placeholders():
	for i in range(number_of_card_placeholders):
		var pos_x = x_difference_between_cards * i + x_difference_between_cards/2 + x_offset_troops
		var new_card_placeholder = card_placeholder.instantiate()
		new_card_placeholder.position = Vector2(pos_x, 0)
		new_card_placeholder.enemy = false
		new_card_placeholder.place = i
		$player_troops.add_child(new_card_placeholder)


func _on_button_pressed() -> void:
	for i in range(num_cards_to_choose):
		if cards_to_choose[i].chosen == false:
			var old_card = cards_to_choose[i]
			var new_card_placeholder = card_choose.instantiate()
			new_card_placeholder.position = old_card.global_position
			cards_to_choose[i] = new_card_placeholder
			old_card.queue_free()
	for card in cards_to_choose:
		var new_card_on_hand = card_on_hand.instantiate()
		new_card_on_hand.position = card.position
		cards_on_hand.append(new_card_on_hand)
		$player_hand.add_child(new_card_on_hand)
	$player_choose.visible = false
	$ColorRect.visible = false
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
	
func arrange_cards_in_hand(cards: Array, center_pos: Vector2, spacing: float = 100.0, max_angle: float = 12.0, max_height: float = 50.0):
	var n = cards.size()
	if n == 0:
		return
	# Calculate start index relative to center
	for i in range(n):
		var t = i / float(n - 1) if n > 1 else 0.5  # t goes from 0 (left) to 1 (right)

		# Horizontal position: spread cards evenly around center
		var x_offset = lerp(-spacing * (n-1)/2, spacing * (n-1)/2, t)

		# Vertical position: peak in the middle, lower on the sides (parabola)
		var y_offset = -4 * max_height * (t - 0.5) * (t - 0.5) + max_height

		# Rotation: tilt cards to the sides
		var angle = lerp(-max_angle, max_angle, t)

		# Apply to card
		var card = cards[i]
		card.position = center_pos + Vector2(x_offset, -y_offset)
		card.rotation_degrees = angle
		print(card.global_position.x, card.global_position.y)

func change_chosen_card(node):
	if card_on_hand_and_chosen == null:
		card_on_hand_and_chosen = node
		card_on_hand_and_chosen.make_chosen()
	else:
		card_on_hand_and_chosen.make_unchosen()
		card_on_hand_and_chosen = node
		card_on_hand_and_chosen.make_chosen()
	
func clicked_placeholder(node):
	if card_on_hand_and_chosen != null and turn == 1:
		if card_on_hand_and_chosen.card_type == CardType.MINION and node.is_occupied == false and node.enemy == false:
			node.is_occupied = true
			node.get_node("Minion").visible = true
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
		elif card_on_hand_and_chosen.card_type == CardType.ARSENAL and node.is_occupied == true and node.have_weapon == false and node.enemy == false:
			node.is_occupied = true
			node.get_node("Arsenal").visible = true
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
		elif card_on_hand_and_chosen.card_type == CardType.MIXTURE_HEAL and node.is_occupied == true and node.enemy == false:
			# node.strength += card_on_hand_and_chosen.value
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
		elif card_on_hand_and_chosen.card_type == CardType.MIXTURE_DMG and node.is_occupied == true and node.enemy == true:
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
		elif card_on_hand_and_chosen.card_type == CardType.MIXTURE_DRAW:
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			var n_cards = card_on_hand_and_chosen.value
			for i in range(n_cards):
				if hand_size > cards_on_hand.size():
					var new_card_on_hand = card_on_hand.instantiate()
					cards_on_hand.append(new_card_on_hand)
					$player_hand.add_child(new_card_on_hand)
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
		turn = 0
		enemy_move()
func clicked_boss(node):
	if card_on_hand_and_chosen != null and turn == 1:
		if card_on_hand_and_chosen.card_type == CardType.MIXTURE_DMG:
			cards_on_hand.erase(card_on_hand_and_chosen)
			card_on_hand_and_chosen.queue_free()
			arrange_cards_in_hand(cards_on_hand, Vector2(0,80))
			turn = 0
			enemy_move()

#EnemyMove { MIXTURE_DMG, MIXTURE_HEAL, MINION, ARSENAL }
func enemy_move():
	print("Starting...")
	await get_tree().create_timer(1.0).timeout
	print("1 second later!")
	var moved = false
	var move
	var value
	while not moved:
		move = EnemyMove.values()[randi() % EnemyMove.size()]
		if move == EnemyMove.MIXTURE_DMG:
			print("trying MIXTURE DMG")
			value = randi() % 3 + 1
			var children = $player_troops.get_children()
			var num_of_children = 0
			for child in children:
				if child.is_occupied:
					num_of_children = num_of_children + 1
			if num_of_children > 0:
				var random_child = randi() % num_of_children
				var child_node = children[random_child]
				if child_node.is_occupied == true:
					if child_node.stats > 0:
						child_node.stats = child_node.stats - value
						moved = true
						print("moved MIXTURE DMG")
		elif move == EnemyMove.MIXTURE_HEAL:
			print("trying MIXTURE HEAL")
			value = randi() % 2 + 1
			var children = $enemy_troops.get_children()
			var num_of_children = 0
			for child in children:
				if child.is_occupied:
					num_of_children = num_of_children + 1
			if num_of_children > 0:
				var random_child = randi() % num_of_children
				var child_node = children[random_child]
				if child_node.is_occupied == true:
					if child_node.stats < child_node.max_stats:
						child_node.stats = child_node.stats + value
						if child_node.stats > child_node.max_stats:
							child_node.stats = child_node.max_stats
						moved = true
						print("moved MIXTURE_HEAL")
		elif move == EnemyMove.ARSENAL:
			print("trying ARSENAL")
			value = randi() % 4 + 1
			var children = $enemy_troops.get_children()
			var num_of_children = 0
			for child in children:
				if child.is_occupied:
					num_of_children = num_of_children + 1
			if num_of_children > 0:
				var random_child = randi() % num_of_children
				var child_node = children[random_child]
				if child_node.is_occupied == true:
					if child_node.have_weapon == false:
						child_node.weapon_stats = value
						child_node.have_weapon = true
						child_node.get_node("Arsenal").visible = true
						moved = true
					# VISIBLE ARSENALrandom_child.
						print("moved ARSENAL")
		elif move == EnemyMove.MINION:
			print("trying MINION")
			value = randi() % 2 + 1
			var children = $enemy_troops.get_children()
			var num_of_children = 0
			for child in children:
				if child.is_occupied:
					num_of_children = num_of_children + 1
			if num_of_children < number_of_card_placeholders:
				var random_child = randi() % (number_of_card_placeholders - num_of_children)
				var child_node = children[random_child]
				if child_node.is_occupied == false:
					child_node.stats = value
					child_node.is_occupied = true
					child_node.get_node("Minion").visible = true
					moved = true
					print("moved MINION")
	turn = 1
	turns_left = turns_left - 1
	$number_of_turns_left.text = str(turns_left)

		
