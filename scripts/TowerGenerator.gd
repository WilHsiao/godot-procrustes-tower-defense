# TowerGenerator.gd
extends Node

var game_board
var grid_size
var cell_size

func _ready():
	game_board = get_parent()
	grid_size = game_board.grid_size
	cell_size = game_board.cell_size

func generate_towers():
	var board_data = get_board_data_with_colors()
	blacken_isolated_cells(board_data)
	calculate_area_connections(board_data)
	second_process_cells(board_data)

	print("Starting tower generation process...")
	print("Board data retrieved.")
	blacken_isolated_cells(board_data)
	print("Isolated cells blackened.")
	calculate_area_connections(board_data)
	print("Area connections calculated.")
	second_process_cells(board_data)
	print("Tower generation complete.")

func get_board_data_with_colors():
	var board_data = []
	for y in range(grid_size.y):
		board_data.append([])
		for x in range(grid_size.x):
			var cell_color = game_board.get_cell_color(Vector2(x, y))
			board_data[y].append({
				"color": cell_color,
				"content": null,
				"note": null,
				"should_process": cell_color != Color.BLACK and cell_color != Color.WHITE
			})
	return board_data

func blacken_isolated_cells(board_data):
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell_data = board_data[y][x]
			if cell_data.color == Color.BLACK or cell_data.color == Color.WHITE:
				continue
			if not has_adjacent_same_color(board_data, x, y, cell_data.color) and not cell_data.content:
				game_board.set_cell_color(Vector2(x, y), Color.BLACK)
				cell_data.color = Color.BLACK

func has_adjacent_same_color(board_data, x, y, color):
	var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for direction in directions:
		var new_x = x + direction.x
		var new_y = y + direction.y
		if new_x >= 0 and new_x < grid_size.x and new_y >= 0 and new_y < grid_size.y:
			if board_data[new_y][new_x].color == color:
				return true
	return false

func calculate_area_connections(board_data):
	var visited = []
	for y in range(grid_size.y):
		visited.append([])
		for x in range(grid_size.x):
			visited[y].append(false)
	
	var allowed_colors = [Color(1, 0.67, 0.67), Color(1, 1, 0.67), Color(0.67, 1, 0.67),Color(0.67, 0.67, 1), Color(0.9, 0.67, 1)]  # 淡紅、淡黃、淡綠、淡藍、淡紫
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell_color = board_data[y][x].color
			if cell_color in allowed_colors and not visited[y][x]:
				var connected_cells = find_connected_cells(board_data, x, y, cell_color, visited)
				var count = connected_cells.size()
				for cell in connected_cells:
					board_data[cell.y][cell.x].note = count

func find_connected_cells(board_data, start_x, start_y, color, visited):
	var queue = [Vector2(start_x, start_y)]
	var connected_cells = []
	
	while not queue.is_empty():
		var cell = queue.pop_front()
		var x = cell.x
		var y = cell.y
		
		if visited[y][x]:
			continue
		visited[y][x] = true
		
		if board_data[y][x].color == color:
			connected_cells.append(cell)
			var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
			for direction in directions:
				var new_x = x + direction.x
				var new_y = y + direction.y
				if new_x >= 0 and new_x < grid_size.x and new_y >= 0 and new_y < grid_size.y and not visited[new_y][new_x]:
					if board_data[new_y][new_x].color == color:
						queue.append(Vector2(new_x, new_y))
	
	return connected_cells

func second_process_cells(board_data):
	var processed = []
	for y in range(grid_size.y):
		processed.append([])
		for x in range(grid_size.x):
			processed[y].append(false)

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell_color = board_data[y][x].color
			if cell_color != Color.BLACK and cell_color != Color.WHITE and not processed[y][x]:
				second_process_area(x, y, board_data, processed)

func second_process_area(start_x, start_y, board_data, processed):
	var target_color = board_data[start_y][start_x].color
	var stack = [Vector2(start_x, start_y)]
	var cells_to_evaluate = []
	var content_sum = 0
	var empty_count = 0
	var center = Vector2(3, 5)  # E7 的索引

	while not stack.is_empty():
		var cell = stack.pop_back()
		var x = cell.x
		var y = cell.y

		if processed[y][x]:
			continue
		processed[y][x] = true

		var cell_value = board_data[y][x].content
		if cell_value != null:
			content_sum += cell_value
		else:
			empty_count += 1

		cells_to_evaluate.append({"pos": cell, "value": cell_value})

		var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
		for direction in directions:
			var new_x = x + direction.x
			var new_y = y + direction.y
			if new_x >= 0 and new_x < grid_size.x and new_y >= 0 and new_y < grid_size.y:
				if board_data[new_y][new_x].color == target_color and not processed[new_y][new_x]:
					stack.append(Vector2(new_x, new_y))

	var final_number = content_sum + empty_count

	if final_number < 3:
		for cell in cells_to_evaluate:
			game_board.set_cell_color(cell.pos, Color.BLACK)
			board_data[cell.pos.y][cell.pos.x].content = null
			board_data[cell.pos.y][cell.pos.x].note = null
		return

	for cell in cells_to_evaluate:
		cell.score = 0
		if cell.value != null:
			cell.score += cell.value
		var distance_to_center = abs(cell.pos.x - center.x) + abs(cell.pos.y - center.y)
		cell.score -= distance_to_center

		var directions = [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1),
						  Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)]
		for direction in directions:
			var new_x = cell.pos.x + direction.x
			var new_y = cell.pos.y + direction.y
			if new_x >= 0 and new_x < grid_size.x and new_y >= 0 and new_y < grid_size.y:
				if board_data[new_y][new_x].color == Color.WHITE:
					cell.score += 1

	cells_to_evaluate.sort_custom(Callable(self, "compare_cells"))
	var representative_cell = cells_to_evaluate[0]

	for cell in cells_to_evaluate:
		if cell.pos != representative_cell.pos:
			game_board.set_cell_color(cell.pos, Color.BLACK)
			board_data[cell.pos.y][cell.pos.x].content = null
			board_data[cell.pos.y][cell.pos.x].note = null
		else:
			board_data[cell.pos.y][cell.pos.x].content = final_number
			# 在這裡添加生成塔的邏輯

func compare_cells(a, b):
	return a.score > b.score
