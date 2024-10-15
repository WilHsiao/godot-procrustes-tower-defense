# Monster.gd

extends Node2D

var monster_type: String
var health: int
var reward: int
var color: Color
var speed: int

func initialize(type: String, hp: int, rew: int, col: Color, spd: int):
	monster_type = type
	health = hp
	reward = rew
	color = col
	speed = spd
	update_visual()

func move_to(new_position: Vector2):
	position = new_position

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		queue_free()
	update_visual()

func update_visual():
	$ColorRect.color = color
	$Label.text = str(health)

func _ready():
	$ColorRect.size = Vector2(64, 64)  # 假设格子大小为 64x64
	$Label.size = Vector2(64, 64)
