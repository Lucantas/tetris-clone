extends Node2D

const GRID_SIZE = Vector2(32,32)

var row : int = 20
var column : int = 10
var offset_height = 3
var offset_width = 2

var computed_board_row = row + offset_height
var computed_board_column = column + offset_width
var show_grid = true

onready var grid : Dictionary = create_grid(column, row, 0, show_grid)

onready var game_speed : float = 1
onready var timer = $Timer

var draw_color = Color(123, 123, 123, 0.1)

func _ready():	
	timer.wait_time = 1.5 - (game_speed/10.0)
	timer.start()
	var board_width = GRID_SIZE.x * column
	var board_height = GRID_SIZE.y * row
	var ui_width = board_width / 2
	#OS.set_window_size(Vector2(board_width + ui_width, GRID_SIZE.y * row))	
	
func _process(delta):
	timer.wait_time = 1.5 - (game_speed/10.0)

func _draw():
	draw_board_panel()
	create_grid(column,row,0,show_grid)
	
func draw_board_panel():
	# right
	draw_line(
		Vector2(GRID_SIZE.x * computed_board_column,offset_height * GRID_SIZE.y), 
		Vector2(GRID_SIZE.x * computed_board_column,GRID_SIZE.y * computed_board_row),
		draw_color,
		1
	)
	# bottom
	draw_line(
		Vector2(GRID_SIZE.x * offset_width,GRID_SIZE.y * computed_board_row),
		Vector2(GRID_SIZE.x * computed_board_column,GRID_SIZE.y * computed_board_row),
		draw_color,
		1
	)	
	
func is_block_free(block_position : Vector2) -> bool:
	for piece in $PieceHolder.get_children():
		for block in piece.get_children():
			if block.global_position.round() == block_position.round():
				return false
	return true
	
func create_grid(width, height, value, draw, offset_h = offset_height, offset_w = offset_width) -> Dictionary:
	var a = {}
	for y in range(offset_h, offset_h + height):
		var row_blocks = [] # hold blocks with value 1 
		a[str(y)] = {}
		
		for x in range(offset_w, offset_w + width):			
			var pos = Vector2((x * GRID_SIZE.x) + 16, (y * GRID_SIZE.y) + 16)
			a[str(y)][str(x)] = 0 if is_block_free(pos) else 1		 
			if not is_block_free(pos):
				row_blocks.append(pos)
				
			if draw:
				# draw vertical lines
				var from = Vector2(x * GRID_SIZE.x, y * GRID_SIZE.y)
				var to = Vector2(
					x * GRID_SIZE.x,
					(y * GRID_SIZE.y) + GRID_SIZE.y
				)
				
				draw_line(from, to, draw_color, 1)
				# draw horizontal lines
				from = Vector2(x * GRID_SIZE.x, y * GRID_SIZE.y)
				to = Vector2(
					(x * GRID_SIZE.x) + GRID_SIZE.x,
					y * GRID_SIZE.y
				)
				
				draw_line(from, to, draw_color, 1)		
		
		if len(row_blocks) == width:
			# all blocks in the row are filled
			# TODO: 
			# 	- remove all blocks from the row
			# 	- update all rows on top of the filled rows to 
			# have their y decremented by the grid height
			
			# loop over the blocks in the array
			var row_to_drop
			for pos in row_blocks:			
				# remove all the blocks with that position from the PieceHolder
				row_to_drop = pos.y
				
			for x in range(offset_w, offset_w + width):					
				a[str(y)][str(x)] = 0
			clear_row(row_to_drop)			
									
			
		
	return a
	
func clear_row(row):
	fix_position()
	#TODO: optimization of this method, do all that is needed from the 
	# $PieceHolder children on one loop
	for piece in $PieceHolder.get_children():
		for block in piece.get_children():
			var t = block.global_position
			if block.global_position.y == row:
				block.queue_free()
				
	# loop again to update the blocks position as the row is falling
	for piece in $PieceHolder.get_children():
		for block in piece.get_children():
			if block.global_position.y < row:
				block.global_position.y = block.global_position.y + GRID_SIZE.y
				
func fix_position():
	$Player.fix_position()
	for piece in $PieceHolder.get_children():
		for block in piece.get_children():
			block.global_position = Vector2(
				$Player.round_to_nearest_multiple(block.global_position.x,16),
				$Player.round_to_nearest_multiple(block.global_position.y,16)				
			)
			if block.global_position.y == row:
				block.queue_free()

#TODO: Separate ui stuff
func _on_RestartBtn_button_up():
	new_game()

func new_game():
	clear_table()
	$Player.retrieve_piece()
	play()
	
func clear_table():
	# iterate over children nodes in order to delete them
	$Player.clear()
	for i in $PieceHolder.get_children():
		i.queue_free()
	

func _on_PauseBtn_button_up():
	if $PauseBtn.text.to_upper() == "PLAY":
		play()
	else:
		pause()

func pause():
	$PauseBtn.text = "Play"
	timer.stop()
	
func play():
	$PauseBtn.text = "Pause"
	timer.start()