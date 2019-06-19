extends Node2D

onready var game = get_tree().get_root().get_node( "Main" )
# TODO: load the other pieces
onready var pieces = ["res://pieces/I_Piece.tscn",
					 "res://pieces/I_Piece.tscn",
					 "res://pieces/I_Piece.tscn"]

var rotation_default = 90

func _ready():	
	randomize()
	retrieve_piece()	
	# TODO: randomize again to get the next piece, to be displayed at the user
	

func _input(event):
	if event is InputEventKey:
		# TODO: listen to the inpts to move and rotate the piece
		_handle_piece_rotation()
		_handle_horizontal_move()
		_handle_bottom_move()
		
		
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
	if Input.is_action_just_pressed("ui_up"):
		self.rotation_degrees += rotation_default
		update_grid()
		
func _handle_horizontal_move():
	update_grid()
	var LEFT : int = _move_piece_left()
	var RIGHT : int = _move_piece_right()
	
	self.position += Vector2( ( RIGHT - LEFT ) * game.GRID_SIZE.x, 0 )

func _move_piece_left():
	var LEFT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			if int((i.global_position.x+8) / game.GRID_SIZE.x ) == 0:
				return 0
				
	LEFT = int( Input.is_action_just_pressed( "ui_left" ) )
	
	return LEFT	
	
func _move_piece_right():
	var RIGHT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			if int((i.global_position.x +16)/ game.GRID_SIZE.x) == game.column:
				return 0
		
	RIGHT = int( Input.is_action_just_pressed( "ui_right" ) )
	
	return RIGHT
	
func _handle_bottom_move():	
	if Input.is_action_just_pressed( "ui_down" ):	
		move_bottom()
		
func move_bottom():	
	var botton_row = game.row
	
	update_grid()
	if get_child(0) != null:
		for i in get_child(0).piece_blocks_positions:
			var one_block_position = i.y +.5
			prints(botton_row, one_block_position,i)
			if  one_block_position >= botton_row:
				place_piece()
				return
						
	self.position.y += game.GRID_SIZE.y
	
func update_grid():
	game.grid = game.create_grid(game.column, game.row, 0)
	
	if get_child(0) != null:
		prints("SHOW TIME: ", get_child(0).global_position)
		for i in get_child(0).piece_blocks_positions:
			if i.x < game.column && i.x > 0:				
				prints(i.x, i.y)
				game.grid[int(i.y)][int(i.x)] = 1
	
	
func place_piece():
	var piece = get_child(0)
	var piece_position = piece.global_position
	var piece_rotation = piece.global_rotation
	
	remove_child(piece)
	
	piece.global_position = piece_position
	piece.global_rotation = piece_rotation
	
	get_parent().add_child(piece)
	
	self.position = Vector2( OS.get_window_size().x/2+8, 8 )
	retrieve_piece()
	
	
	
	