# MonsterManager.gd

extends Node2D

var game_board
var current_run = 0
var monster = null

# 怪物预制体，需要在编辑器中设置
@export var monster_scene: PackedScene

func _ready():
	game_board = get_parent()
	if not game_board:
		push_error("MonsterManager: Parent node is not set")

func start_new_run():
	current_run += 1
	create_monster()

func create_monster():
	var rand = randf() * 100
	var monster_type = "一般怪物"
	var health = current_run * 30
	var reward = 5
	var color = Color(0.545, 0, 0)  # 深红色
	var speed = 1
	
	if rand < 66:
		# 一般怪物，使用默认值
		pass
	elif rand < 76:
		monster_type = "防禦菁英怪"
		health = current_run * 45
		reward = 10
		color = Color(0, 0, 0.545)  # 深蓝色
	elif rand < 86:
		monster_type = "速度菁英怪"
		health = current_run * 25
		reward = 10
		color = Color(0, 0.392, 0)  # 深绿色
		speed = 2
	elif rand < 96:
		monster_type = "再生菁英怪"
		health = current_run * 20
		reward = 10
		color = Color(1, 0.6, 0)  # 橙色
	else:
		monster_type = "寶箱怪"
		health = 100
		reward = 30
		color = Color(1, 0.843, 0)  # 金色

	monster = monster_scene.instantiate()
	monster.initialize(monster_type, health, reward, color, speed)
	add_child(monster)
	
	spawn_monster()

func spawn_monster():
	var spawn_points = game_board.find_white_cells_in_range(Vector2i(0, 0), Vector2i(12, 0))
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		var world_position = game_board.map_to_world(spawn_point)
		
		if monster:
			monster.position = world_position
			print("Monster spawned at world position: ", world_position)
		else:
			print("Error: Monster not initialized")
	else:
		print("No valid spawn points found")

func move_monster():
	if monster and monster.health > 0:
		var monster_map_pos = game_board.local_to_map(monster.position)
		var next_positions = game_board.get_adjacent_white_cells(monster_map_pos)
		if next_positions.size() > 0:
			var next_position = next_positions[randi() % next_positions.size()]
			monster.move_to(game_board.map_to_local(next_position))
		else:
			print("No valid positions for monster to move.")

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
			monster.health += current_run
			print("Regenerative monster healed for ", current_run, " health.")
		# 更新怪物的视觉表现
		monster.update_visual()
