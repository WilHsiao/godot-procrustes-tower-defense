# PathDrawer.gd

extends Node2D

var game_board
var current_path = []
var is_drawing = false
var cell_size = Vector2(128, 128)  # 确保与 GameBoard 中的 cell_size 一致
var preview_color = Color(1, 1, 1, 0.5)  # 半透明白色

func _ready():
	game_board = get_parent()
	if not game_board or not game_board.has_method("set_cell_color"):
		push_error("PathDrawer: Parent node is not a valid GameBoard")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing(event.position)
			else:
				stop_drawing()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drawing()
	elif event is InputEventMouseMotion:
		if is_drawing:
			continue_drawing(event.position)
	elif event is InputEventKey:
		if event.pressed and event.keycode == KEY_Z:
			undo_last_point()
	queue_redraw()
	
func start_drawing(position):
	is_drawing = true
	current_path.clear()
	add_point_to_path(position)

func stop_drawing():
	is_drawing = false
	process_path()

func continue_drawing(position):
	add_point_to_path(position)

func add_point_to_path(position):
	var grid_pos = (position / cell_size).floor()
	if is_valid_grid_position(grid_pos) and (current_path.is_empty() or grid_pos != current_path[-1]):
		current_path.append(grid_pos)
		game_board.set_cell_color(grid_pos, Color.WHITE)  # 立即更新颜色

func is_valid_grid_position(grid_pos):
	return grid_pos.x >= 0 and grid_pos.x < game_board.grid_size.x and \
		grid_pos.y >= 0 and grid_pos.y < game_board.grid_size.y

func process_path():
	if current_path.size() < 2:
		return

	var valid_path = []
	for i in range(1, current_path.size()):
		var from = current_path[i-1]
		var to = current_path[i]
		if are_adjacent(from, to):
			valid_path.append(from)
		else:
			break
	valid_path.append(current_path[-1])
	
	update_game_board(valid_path)

func are_adjacent(pos1, pos2):
	return (pos1 - pos2).length() == 1

func update_game_board(path):
	if game_board:
		for pos in path:
			game_board.set_cell_color(pos, Color.WHITE)
	queue_redraw()

func cancel_drawing():
	for pos in current_path:
		game_board.set_cell_color(pos, game_board.get_original_color(pos))
	is_drawing = false
	current_path.clear()
	queue_redraw()

func undo_last_point():
	print("PathDrawer: Attempting to undo last point")
	if current_path.size() > 0:
		var removed_point = current_path.pop_back()
		print("PathDrawer: Removed point ", removed_point)
		game_board.set_cell_color(removed_point, game_board.get_original_color(removed_point))
		queue_redraw()
	else:
		print("PathDrawer: No points to undo")

func _draw():
	if current_path.size() < 2:
		return
	
	for i in range(1, current_path.size()):
		var from = current_path[i-1] * cell_size + cell_size / 2
		var to = current_path[i] * cell_size + cell_size / 2
		draw_line(from, to, preview_color, 4.0)  # 使用半透明颜色和更粗的线条
		
		# 在每个转折点绘制一个圆
		draw_circle(from, 5, preview_color)
	
	# 在路径的最后一个点绘制一个圆
	draw_circle(current_path[-1] * cell_size + cell_size / 2, 5, preview_color)

func _process(delta):
	if Input.is_key_pressed(KEY_Z):
		print("Z key is directly detected as pressed")
		undo_last_point()
