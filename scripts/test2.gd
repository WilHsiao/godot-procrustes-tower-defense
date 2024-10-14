# PathDrawer.gd

extends Node2D

signal  path_completed

var game_board
var current_path = []
var preview_path = []
var is_drawing = false
var cell_size = Vector2(128, 128)  # 與 GameBoard.gd 的尺寸一致
var preview_color = Color(1, 1, 1, 0.5)  # 最後一個是透明度白色
var confirmed_color = Color.WHITE
var board_offset = Vector2(0, -128)  # 與 GameBoard 中的偏移相同

func _ready():
	print("PathDrawer is ready")
	game_board = get_parent()
	if not game_board or not game_board.has_method("set_cell_color"):
		push_error("PathDrawer: Parent node is not a valid GameBoard")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		print("Mouse button event received in PathDrawer:", event)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing(event.position)
			else:
				stop_drawing()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drawing()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and is_drawing:
		print("Mouse motion event received in PathDrawer:", event.position)  # Debug output
		continue_drawing(event.position)
		get_viewport().set_input_as_handled()
	
	queue_redraw()

func start_drawing(position):
	is_drawing = true
	current_path.clear()
	preview_path.clear()
	add_point_to_path(position)

func stop_drawing():
	is_drawing = false
	confirm_preview_path()
	emit_signal("path_completed")

func continue_drawing(position):
	add_point_to_path(position)

func add_point_to_path(position):
	var grid_pos = ((position - board_offset) / cell_size).floor()
	if is_valid_next_point(grid_pos):
		if current_path.is_empty() or grid_pos != current_path[-1]:
			current_path.append(grid_pos)
			game_board.set_cell_color(grid_pos, preview_color)
			print("Added point to path:", grid_pos)

func is_valid_next_point(pos):
	if not game_board.is_valid_position(pos) or game_board.get_cell_color(pos) == Color.BLACK:
		return false
	if current_path.is_empty() or are_adjacent(pos, current_path[-1]):
		return true
	return false

func confirm_preview_path():
	for pos in current_path:
		game_board.set_cell_color(pos, confirmed_color)
	preview_path.clear()

func are_adjacent(pos1, pos2):
	return (pos1 - pos2).length() == 1

func cancel_drawing():
	for pos in current_path:
		if game_board.get_cell_color(pos) != Color.BLACK:
			game_board.set_cell_color(pos, game_board.get_original_color(pos))
	current_path.clear()
	preview_path.clear()
	queue_redraw()

func undo_last_point():
	print("Attempting to undo last point")
	if current_path.size() > 0:
		var removed_point = current_path.pop_back()
		print("Undo: Removed last point at ", removed_point, ". Current path size: ", current_path.size())
		game_board.set_cell_color(removed_point, game_board.get_original_color(removed_point))
		queue_redraw()
	else:
		print("Undo: No points to remove")

func _draw():
	if current_path.size() < 2:
		return
	
	for i in range(1, current_path.size()):
		var from = current_path[i-1] * cell_size + cell_size / 2 + board_offset
		var to = current_path[i] * cell_size + cell_size / 2 + board_offset
		draw_line(from, to, preview_color, 4.0)
		
		draw_circle(from, 5, preview_color)
	
	draw_circle(current_path[-1] * cell_size + cell_size / 2 + board_offset, 5, preview_color)
