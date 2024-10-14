# GameBoard.gd

extends Node2D

var grid_size = Vector2(7, 11)
var colors = [Color.RED, Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE]
var board = []
var original_colors = []
var cell_size = Vector2(128, 128)  # 设置每个格子的大小

func _ready():
	randomize()
	generate_game_board()

func generate_game_board():
	board = []
	original_colors = []  # 初始化原始颜色数组
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			row.append(null)
		board.append(row)
		
	generate_random_black_points()
	generate_continuous_color_areas()
	fill_remaining_colors()
	queue_redraw()  # 请求重新绘制
	print("Game board generated")

func generate_random_black_points():
	var black_point_count = 3  # You can adjust this value
	for _i in range(black_point_count):
		var x = randi() % int(grid_size.x)
		var y = randi() % int(grid_size.y)
		while board[y][x] != null:
			x = randi() % int(grid_size.x)
			y = randi() % int(grid_size.y)
		board[y][x] = Color.BLACK

func generate_continuous_color_areas():
	var area_sizes = [3, 3, 4]  # You can adjust these values
	for size in area_sizes:
		var color = colors[randi() % colors.size()]
		var start_pos = find_valid_start_position()
		if start_pos:
			generate_area(start_pos, color, size)

func find_valid_start_position():
	var valid_positions = []
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if board[y][x] == null:
				valid_positions.append(Vector2(x, y))

	if valid_positions.size() > 0:
		return valid_positions[randi() % valid_positions.size()]
	return null

func generate_area(start_pos, color, size):
	var positions = [start_pos]
	board[start_pos.y][start_pos.x] = color

	for _i in range(size - 1):
		var next_pos = get_next_valid_position(positions)
		if next_pos:
			positions.append(next_pos)
			board[next_pos.y][next_pos.x] = color
		else:
			break

func get_next_valid_position(positions):
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	var valid_positions = []

	for pos in positions:
		for dir in directions:
			var new_pos = pos + dir
			if is_valid_position(new_pos) and board[new_pos.y][new_pos.x] == null:
				valid_positions.append(new_pos)

	if valid_positions.size() > 0:
		return valid_positions[randi() % valid_positions.size()]
	return null

func is_valid_position(pos):
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func fill_remaining_colors():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if board[y][x] == null:
				board[y][x] = colors[randi() % colors.size()]

func set_cell_color(pos, color):
	board[pos.y][pos.x] = color
	queue_redraw()

func _draw():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var rect = Rect2(x * cell_size.x, y * cell_size.y, cell_size.x, cell_size.y)
			var color = Color.WHITE if board[y][x] == null else board[y][x]
			draw_rect(rect, board[y][x])
			draw_rect(rect, Color.BLACK, false)  # 绘制格子边框
