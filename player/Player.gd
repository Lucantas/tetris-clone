extends Node2D

onready var game = get_tree().get_root().get_node( "Main" )
# TODO: load the other pieces
onready var pieces = ["res://pieces/I_Piece.tscn",
					 "res://pieces/S_Piece.tscn"]

var rotation_default = 90

func _ready():	
	randomize()
	retrieve_piece()	
	# TODO: randomize again to get the next piece, to be displayed at the user
	

func _input(event):
	if event is InputEventKey:
		# TODO: listen to the inpts to move and rotate the piece
		pass
		
		
func retrieve_piece():
	var temp
	var piece
	
	# make sure to only retrieve a piece when there is no other with the player
	if get_child_count() == 0:		
		var next_piece = str(pieces[randi() % pieces.size()])		
		temp = load(next_piece)
		piece = temp.instance()
		self.add_child(piece)					

func _handle_piece_rotation():
	if Input.is_action_just_pressed("up"):
		self.rotation_degrees += rotation_default
		update_grid()
		
func _move_piece_horizontal_action():
	update_grid()
	var LEFT : int = _move_piece_left()
	var RIGHT : int = _move_piece_right()

func _move_piece_left():
	# TODO
	pass	
	
func _move_piece_right():
	# TODO
	pass
	
func update_grid():
	game.grid = game.create_grid(game.column, game.row, 0)
	
	if get_child(0) != null:
		for i in get_child(0).pieces_positions:
			if i.x < game.column && i.x > 0:
				game.grid[int(i.y)][int(i.x)] = 1
	
	
	
	
	
	
	
	
	