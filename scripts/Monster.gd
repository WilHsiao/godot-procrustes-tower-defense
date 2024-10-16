# Monster.gd

extends Node2D

var monster_type: String
var health: int
var reward: int
var color: Color
var speed: int
var regen: int = 0

func _ready():
	print("Monster _ready called. Initial position:", position)
	$ColorRect.size = Vector2(128, 128)  # 确保这与 GameBoard 的 cell_size 匹配
	$Label.size = Vector2(128, 128)  # 标签也应该匹配格子大小

func _process(delta):
	if position != global_position:
		print("Warning: Monster local position and global position mismatch")
		print("Local position:", position)
		print("Global position:", global_position)

func initialize(type: String, hp: int, rew: int, col: Color, spd: int):
	print("Monster initialize called with type:", type, "hp:", hp, "reward:", rew, "color:", col, "speed:", spd)
	monster_type = type
	health = hp
	reward = rew
	color = col
	speed = spd
	update_visual()
	print("Monster initialized. Current position:", position)

func set_regen(value: int):
	regen = value
	print("Regen set to:", regen)

func apply_regen():
	if monster_type == "再生菁英怪":
		health += regen
		print("Regenerative monster healed for", regen, "health. New health:", health)

func move_to(new_position: Vector2):
	print("Monster moving from", global_position, "to", new_position)
	global_position = new_position
	print("Monster moved. New position:", global_position)
	update_visual()

func take_damage(damage: int):
	print("Monster taking damage:", damage, "Current health:", health)
	health -= damage
	if health <= 0:
		print("Monster health depleted. Queuing for free.")
		queue_free()
	else:
		update_visual()

func update_visual():
	print("Updating monster visual. Color:", color, "Health:", health)
	$ColorRect.color = color
	$Label.text = str(health)
	print("Visual update complete. ColorRect color:", $ColorRect.color, "Label text:", $Label.text)

func print_status():
	print("Monster status - Type:", monster_type, "Health:", health, "Position:", global_position, "Color:", color, "Speed:", speed, "Regen:", regen)
