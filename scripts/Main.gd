extends Node2D

@onready var game_board = $GameBoard
@onready var reset_button = $ResetButton  # 确保在场景中添加了一个名为 ResetButton 的按钮节点

func _ready():
	if game_board:
		if game_board.has_method("generate_game_board"):
			game_board.generate_game_board()
		else:
			print("Error: GameBoard node found, but it doesn't have the generate_game_board method")
			print("Make sure the GameBoard.gd script is attached to the TileMap node")
	else:
		print("Error: GameBoard node not found")
	
	print("GameBoard node type:", game_board.get_class())

	# 连接重置按钮
	if reset_button:
		reset_button.connect("pressed", Callable(self, "_on_reset_button_pressed"))
	else:
		print("Error: ResetButton not found")

func _on_reset_button_pressed():
	print("Reset button pressed")
	if game_board and game_board.has_method("reset_board"):
		game_board.reset_board()
	else:
		print("Error: Cannot reset game board")
