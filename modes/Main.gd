extends Node2D

const GRID_SIZE = Vector2(16,16)

var row : int = 32
var column : int = 16

onready var grid : Array = create_grid(column, row, 0)

onready var game_speed : float = 1
onready var timer = $Timer

func _ready():
	timer.wait_time = 1.5 - (game_speed/10.0)
	timer.start()
	
	OS.set_window_size(Vector2(GRID_SIZE.x * column, GRID_SIZE.y * row))	
	
func _process(delta):
	timer.wait_time = 1.5 - (game_speed/10.0)


func create_grid(width, height, value) -> Array:
	var a = []

	for y in range(height):
		a.append([])
		a[y].resize(width)

		for x in range(width):
			a[y][x] = value

	return a