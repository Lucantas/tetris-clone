extends Node2D

var is_colliding = false
signal collide

onready var piece_blocks = [$Block1, $Block2, $Block3, $Block4]
onready var piece_blocks_positions = [] setget update_pieces_positions, get_pieces_positions

#TODO: get grid tile value from Main scripts
var _grid_size_reference = 32

func _ready():
	update_pieces_positions(null)

func update_pieces_positions(null):
	piece_blocks_positions = []
	for i in piece_blocks:
		print("on piece: ", i.position)		
		piece_blocks_positions.append( i.global_position / _grid_size_reference )

func get_pieces_positions():
	update_pieces_positions(null)
	return piece_blocks_positions

func _on_Area2D_area_entered(area):
	is_colliding = true
	emit_signal("collide")

	