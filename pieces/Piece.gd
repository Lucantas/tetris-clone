extends Node2D

onready var piece_blocks = [$Block1, $Block2, $Block3, $Block4]
onready var piece_blocks_positions = [] setget update_pieces_positions, get_pieces_positions

func _ready():
	update_pieces_positions(null)

func update_pieces_positions(null):
	piece_blocks_positions = []
	print(piece_blocks)
	for i in piece_blocks:
		piece_blocks_positions.append( i.global_position /16 )

func get_pieces_positions():
	update_pieces_positions(null)
	return piece_blocks_positions

