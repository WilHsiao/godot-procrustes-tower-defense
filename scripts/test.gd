# Main.gd
extends Node2D

@onready var game_board = $GameBoard

func _ready():
	if game_board:
		if game_board.has_method("generate_game_board"):
			game_board.generate_game_board()
			
			# 调整 GameBoard 的位置
			var viewport_size = get_viewport_rect().size
			var board_size = game_board.grid_size * game_board.cell_size
			var x_offset = (viewport_size.x - board_size.x) / 2
			var y_offset = (viewport_size.y - board_size.y) / 2 - 100  # 减少 100 像素以留出底部空间
			
			game_board.position = Vector2(x_offset, y_offset)
			
			# 调整 Generate Towers 按钮的位置
			if game_board.has_node("GenerateTowersButton"):
				var button = game_board.get_node("GenerateTowersButton")
				button.position = Vector2(x_offset, y_offset + board_size.y + 20)  # 将按钮放在游戏板下方
			
			# 调整窗口大小
			var window_size = Vector2(board_size.x, board_size.y + 200)  # 增加 200 像素的底部空间
			get_tree().root.content_scale_size = window_size
			DisplayServer.window_set_size(window_size)
		else:
			print("Error: GameBoard node found, but it doesn't have the generate_game_board method")
			print("Make sure the GameBoard.gd script is attached to the TileMap node")
	else:
		print("Error: GameBoard node not found")
	
	print("GameBoard node type:", game_board.get_class())
