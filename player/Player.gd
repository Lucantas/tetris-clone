extends Node2D

onready var game = get_tree().get_root().get_node( "Main" )
# TODO: load the other pieces
onready var pieces = [
					"res://pieces/S_Piece.tscn",
					"res://pieces/I_Piece.tscn",
					"res://pieces/O_Piece.tscn",
					"res://pieces/Z_Piece.tscn",
					"res://pieces/T_Piece.tscn",					
					]
					
var board_center = Vector2(222,160)

var rotation_default = 270

var can_move = true

func _ready():	
	randomize()
	retrieve_piece()	
	# TODO: randomize again to get the next piece, to be displayed at the user


func _input(event):
	
	if event is InputEventKey:
		_handle_bottom_move()
		_handle_piece_rotation()
		_handle_horizontal_move()
		
func retrieve_piece():
	var temp
	var piece

	# make sure to only retrieve a piece when there is no other with the player
	if get_child_count() == 0:		
		var next_piece = str(pieces[randi() % pieces.size()])		
		temp = load(next_piece)
		piece = temp.instance()		
		self.add_child(piece)				
		self.position = board_center	
		can_move = true	

func _handle_piece_rotation():
	if Input.is_action_just_pressed("ui_up"):
		self.rotation_degrees += rotation_default
		update_grid()
		
func _handle_horizontal_move():
	update_grid()
	var LEFT : int = _move_piece_left()
	var RIGHT : int = _move_piece_right()
	
	
	var position_update = Vector2( ( RIGHT - LEFT ) * game.GRID_SIZE.x, 0 )
			
	self.position += position_update 
			
	

func _move_piece_left() -> int:
	var LEFT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			var column_limit = int((i.global_position.x) / game.GRID_SIZE.x ) == game.offset_width
			var next_move = Vector2(i.global_position.x - 32, i.global_position.y) 
			if column_limit or not game.is_block_free(next_move):
				return 0
				
	LEFT = int( Input.is_action_just_pressed( "ui_left" ) )
	
	return LEFT	
	
func _move_piece_right():
	var RIGHT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			var column_limit = int((i.global_position.x +32)/ game.GRID_SIZE.x) == game.computed_board_column
			var next_move = Vector2(i.global_position.x + 32, i.global_position.y) 
			if column_limit or not game.is_block_free(next_move):
				return 0
		
	RIGHT = int( Input.is_action_just_pressed( "ui_right" ) )
	
	return RIGHT
	
func _handle_bottom_move():	
	if Input.is_action_just_pressed( "ui_down" ):	
		move_bottom()
		
func move_bottom():	
	var botton_row = (game.computed_board_row * game.GRID_SIZE.y) - game.GRID_SIZE.y
	
	update_grid()
	var should_place = false
	if get_child(0) != null:
		fix_position()
		for i in get_child(0).get_children():
			var is_bottom_row = i.global_position.y + 1 >= botton_row
			var next_move = Vector2(i.global_position.x, i.global_position.y + game.GRID_SIZE.y)				
			
			if  is_bottom_row or not game.is_block_free(next_move):
				should_place = true
			
	
	if should_place:
		place_piece()			
		
	self.position.y += game.GRID_SIZE.y
	

func update_grid():
	fix_position()
	game.grid = game.create_grid(game.column, game.row, 0, false)
	
					
func place_piece():
	fix_position()
	var piece = get_child(0)
	var piece_position = piece.global_position
	var piece_rotation = piece.global_rotation
	
	for block in piece.get_children():
		game.occupied_blocks.append(block.global_position)
	
	remove_child(piece)
	
	get_parent().get_node("PieceHolder").add_child(piece)	
	piece.global_rotation = piece_rotation
	piece.global_position = piece_position # + Vector2(0.5, 2)

	self.position = Vector2( OS.get_window_size().x/2+16, 16 )
	retrieve_piece()
	
func round_to_nearest_multiple( n, multiple_ref = 32 ): 

	# Smaller multiple 
	var a = (floor(n / multiple_ref)) * multiple_ref
	
	# Larger multiple 
	var b = a + multiple_ref
	
	# Return of closest of two 
	return (b if n - a > b - n else a) 

	
func round_to_ref(number, ref) -> int:
    return int(number) if number > ref else ref

	
func fix_position():
	#self.position = board_center	
	#self.get_child(0).position = Vector2(0,0)		
	for i in get_child(0).piece_blocks:
		i.global_position = Vector2(
			round_to_nearest_multiple(i.global_position.x,16), 
			round_to_nearest_multiple(i.global_position.y, 16)
		)
			
	
func clear():
	for i in get_children():
		remove_child(i)
		i.queue_free()
	