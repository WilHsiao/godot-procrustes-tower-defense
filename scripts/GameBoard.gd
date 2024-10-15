# GameBoard.gd

extends Node2D

var grid_size = Vector2(13, 7)
var colors = [Color.RED, Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE]
var board = []
var original_colors = []
var cell_size = Vector2(128, 128)  # 格子大小
var board_offset = Vector2(0, 0)  # 向上偏移一個格子的高度

@onready var generate_towers_button = $GenerateTowersButton
@onready var tower_generator = $TowerGenerator

@onready var generate_monster_button = $GenerateMonsterButton
@onready var monster_manager = $MonsterManager

func _ready():
	randomize()
	generate_game_board()
	
	# 連接按鈕的點擊事件
	if generate_towers_button:
		generate_towers_button.connect("pressed", Callable(self, "_on_generate_towers_button_pressed"))
	else:
		print("Error: GenerateTowersButton not found")
	
	if generate_monster_button:
		generate_monster_button.connect("pressed", Callable(self, "_on_generate_monster_button_pressed"))
	else:
		print("Error: GenerateMonsterButton not found")

func _on_generate_towers_button_pressed():
	print("Generate Towers button pressed")
	if tower_generator:
		tower_generator.generate_towers()
	else:
		print("Error: TowerGenerator not found")

func _on_generate_monster_button_pressed():
	print("Generate Monster button pressed")
	if monster_manager:
		monster_manager.create_monster()
	else:
		print("Error: MonsterManager not found")

func generate_towers():
	if has_node("TowerGenerator"):
		$TowerGenerator.generate_towers()
	else:
		print("Error: TowerGenerator node not found")

func generate_game_board():
	board = []
	original_colors = []  # 初始化原始顏色數組
	for y in range(grid_size.y):
		var row = []
		var original_row = []
		for x in range(grid_size.x):
			row.append(null)
			original_row.append(null)
		board.append(row)
		original_colors.append(original_row)
		
	generate_random_black_points()
	generate_continuous_color_areas()
	fill_remaining_colors()
	
	# 複製 board 到 original_colors
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			original_colors[y][x] = board[y][x]
			
	queue_redraw()  # 重新繪製
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
	if is_valid_position(pos):
		board[pos.y][pos.x] = color
		queue_redraw()

func get_cell_color(pos):
	if is_valid_position(pos):
		return board[pos.y][pos.x]
	return Color.BLACK

func get_original_color(pos):
	if is_valid_position(pos):
		return original_colors[pos.y][pos.x]
	return Color.BLACK

func _draw():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var rect = Rect2(
				x * cell_size.x + board_offset.x, 
				y * cell_size.y + board_offset.y, 
				cell_size.x, 
				cell_size.y
			)
			draw_rect(rect, board[y][x])
			draw_rect(rect, Color.BLACK, false)  # 繪製格子邊框

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		print("Key event received in GameBoard:", event.as_text())
		if event.keycode == KEY_Z:
			$PathDrawer.undo_last_point()
		get_viewport().set_input_as_handled()  # 防止事件進一步傳播
