extends Node2D

onready var game = get_tree().get_root().get_node( "Main" )
# TODO: load the other pieces
onready var pieces = ["res://pieces/S_Piece.tscn",
					 "res://pieces/Z_Piece.tscn",
					 "res://pieces/I_Piece.tscn",
					 "res://pieces/O_Piece.tscn",
					 "res://pieces/T_Piece.tscn"]
					
var board_center = Vector2(224,160)

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
		self.get_child(0).position = Vector2(0,0)		
		
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
		
	print(self.position)
	

func _move_piece_left() -> int:
	var LEFT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			if int((i.global_position.x) / game.GRID_SIZE.x ) == game.offset_width:
				return 0
				
	LEFT = int( Input.is_action_just_pressed( "ui_left" ) )
	
	return LEFT	
	
func _move_piece_right():
	var RIGHT : int = 0
	
	if get_child(0) != null:
		for i in get_child(0).get_children():
			var column_limit = int((i.global_position.x +32)/ game.GRID_SIZE.x) == game.computed_board_column
			var next_move = Vector2(i.global_position.x + 64, i.global_position.y) 
			if column_limit or not is_block_free(next_move):
				return 0
		
	RIGHT = int( Input.is_action_just_pressed( "ui_right" ) )
	
	return RIGHT
	
func _handle_bottom_move():	
	if Input.is_action_just_pressed( "ui_down" ):	
		move_bottom()
		
func move_bottom():	
	var botton_row = game.computed_board_row
	
	update_grid()
	var should_place = false
	if get_child(0) != null:
		var t = get_child(0).piece_blocks_positions
		for i in get_child(0).piece_blocks_positions:
			var is_bottom_row = i.y +1 >= botton_row
			var child = get_child(0)
			var next_move = Vector2(i.x, i.y - 32)
			if  is_bottom_row or not is_block_free(next_move):
				should_place = true
	
	if should_place:
		place_piece()			
						
	self.position.y += game.GRID_SIZE.y
	
func update_grid():
	game.grid = game.create_grid(game.column, game.row, 0, false)
	var game_grid = game.grid
	if get_child(0) != null:
		for i in get_child(0).piece_blocks_positions:			
			if i.x < game.computed_board_column && i.x > game.offset_width:				
				print(get_child(0).get_child(0).global_position)
				game.grid[str(int(i.y))][str(int(i.x))] = 1
				
		
	
	
func place_piece():
	var piece = get_child(0)
	var piece_position = piece.global_position
	var piece_rotation = piece.global_rotation
	
	var blocks_positions = []
	for i in piece.piece_blocks_positions:
		blocks_positions.append(i)	
		
	remove_child(piece)
	
	piece.global_position = piece_position
	piece.global_rotation = piece_rotation
	
	get_parent().add_child(piece)	
	game.occupied_blocks.append(blocks_positions)

	self.position = Vector2( OS.get_window_size().x/2+8, 8 )
	retrieve_piece()
	
func round_to_ref(number, ref) -> int:
    return int(number) if number > ref else ref
	
func is_block_free(block_position : Vector2) -> bool:
	for blocks in game.occupied_blocks:
		for i in blocks:
			if i == block_position:
				return false
	return true
	
	
	