# Main.gd
extends Node2D

@onready var game_board = $GameBoard

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
