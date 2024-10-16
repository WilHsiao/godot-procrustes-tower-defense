# MonsterManager.gd

extends Node2D

var game_board
var current_run = 0
var monster = null
var move_timer: Timer
var path = []  # 存储怪物的移动路径

@export var monster_scene: PackedScene

func _ready():
	game_board = get_parent()
	if not game_board:
		push_error("MonsterManager: Parent node is not set")
	else:
		print("MonsterManager: GameBoard reference set successfully")
	
	# 设置移动计时器
	move_timer = Timer.new()
	move_timer.connect("timeout", Callable(self, "_on_move_timer_timeout"))
	add_child(move_timer)

func start_new_run():
	current_run += 1
	create_monster()

func _on_move_timer_timeout():
	move_monster()

func create_monster():
	if monster:
		monster.queue_free()
	
	monster = monster_scene.instantiate()
	add_child(monster)
	
	var rand = randf() * 100
	var monster_data = {}
	
	if rand < 66:
		monster_data = {
			"type": "一般怪物",
			"health": current_run * 30,
			"reward": 5,
			"color": Color(0.545, 0, 0),  # #8B0000
			"speed": 1
		}
	elif rand < 76:
		monster_data = {
			"type": "防禦菁英怪",
			"health": current_run * 45,
			"reward": 10,
			"color": Color(0, 0, 0.545),  # #00008B
			"speed": 1
		}
	elif rand < 86:
		monster_data = {
			"type": "速度菁英怪",
			"health": current_run * 25,
			"reward": 10,
			"color": Color(0, 0.392, 0),  # #006400
			"speed": 2
		}
	elif rand < 96:
		monster_data = {
			"type": "再生菁英怪",
			"health": current_run * 20,
			"reward": 10,
			"color": Color(1, 0.6, 0),  # #ff9900
			"speed": 1,
			"regen": current_run
		}
	else:
		monster_data = {
			"type": "寶箱怪",
			"health": 100,
			"reward": 30,
			"color": Color(1, 0.843, 0),  # #FFD700
			"speed": 1
		}
	
	monster.initialize(
		monster_data["type"],
		monster_data["health"],
		monster_data["reward"],
		monster_data["color"],
		monster_data["speed"]
	)
	
	if "regen" in monster_data:
		monster.set_regen(monster_data["regen"])
	
	print("Created monster: ", monster_data["type"])
	spawn_monster()
	calculate_path()
	move_timer.start(1.0)

func generate_monster():
	print("Generating new monster")
	current_run += 1
	create_monster()

func spawn_monster():
	var spawn_point = game_board.find_leftmost_white_cell()
	if spawn_point != Vector2i(-1, -1):
		var world_position = game_board.map_to_world(spawn_point)
		monster.global_position = world_position
		print("Monster spawned at: ", world_position)
	else:
		push_error("No valid spawn point found")

func calculate_path():
	path = game_board.find_path_to_rightmost_white_cell(game_board.world_to_map(monster.global_position))

func move_monster():
	if monster and monster.health > 0 and not path.is_empty():
		var next_position = path.pop_front()
		var new_world_pos = game_board.map_to_world(next_position)
		monster.move_to(new_world_pos)
		print("Monster moved to: ", new_world_pos)
	elif path.is_empty():
		move_timer.stop()
		print("Monster reached the end of the path")

func handle_monster_explosion():
	if monster and monster.position.y >= game_board.cell_size.y * 11:
		var damage = monster.health
		# 在这里处理对玩家造成伤害的逻辑
		print("Monster exploded, causing ", damage, " damage to player.")
		monster.queue_free()
		monster = null
		return true
	return false

func update_monster_state():
	if monster and monster.health > 0:
		if monster.monster_type == "再生菁英怪":
			monster.apply_regen()
		monster.update_visual()

func reset():
	if monster:
		monster.queue_free()
	monster = null
	current_run = 0
	move_timer.stop()
	path.clear()
	print("MonsterManager has been reset")
