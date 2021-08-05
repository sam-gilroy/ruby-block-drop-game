$gtk.reset

class TetrisGame
  def initialize args
    @args = args
    #game state variables
    @score = 0
    @next_move = 30 # 0.5 seconds at 60 FPS
    @gameover = false
    @grid_w = 10
    @grid_h = 20
    @curr_piece_x = 5
    @curr_piece_y = 0
    @color_index = [
      [0, 0, 0],#0
      [255, 0, 0],#1
      [0, 255, 0],#2
      [0, 0, 255],#3
      [255, 255, 0],#4
      [255, 0, 255],#5
      [0, 255, 255],#6
      [177, 177, 177],#7
      [255, 255, 255]#8
    ]
    @curr_piece = nil
    @next_piece = nil
    select_next_piece
    select_next_piece

    #grid building
    if @grid.nil?
      @grid = []
      for x in 0..@grid_w-1 do
        @grid[x] = []
        for y in 0..@grid_h-1 do
          @grid[x][y] = 0
        end
      end
    end
  end

  #x and y are positions on grid
  def render_block x,y,i,a=255
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h-2) * boxsize)) / 2
    @args.outputs.solids << [grid_x + (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,*@color_index[i],a]
    if i != 8
      @args.outputs.borders << [grid_x + (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,*@color_index[8],a]
    else
      @args.outputs.borders << [grid_x + (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,*@color_index[7],a]
    end
  end

  def render_grid_border x,y,w,h
    color = 8
    for i in x..(x+w)-1 do
      render_block i, y, color
      render_block i, (y+h)-1, color
    end

    for i in y..(y+h)-1 do
      render_block x, i, color
      render_block (x+w)-1, i, color
    end
  end

  def render_background
    @args.outputs.solids << [0,0,1280,720,0,0,0]
    render_grid_border (-1),(-1),@grid_w+2,@grid_h+2
  end

  def render_grid
    for x in 0..@grid_w-1 do
      for y in 0..@grid_h-1 do
        render_block x,y, @grid[x][y] if @grid[x][y]!=0
      end
    end
  end

  def render_piece piece, piece_x, piece_y
    for x in 0..piece.length-1 do
      for y in 0..piece[x].length-1 do
        render_block piece_x + x, piece_y + y,piece[x][y]  if piece[x][y] != 0
      end
    end
  end

  def render_current_piece
    render_piece @curr_piece,@curr_piece_x,@curr_piece_y
  end

  def render_next_piece
    render_grid_border 13,2,8,8
    center_x = (8-@next_piece.length)/2
    center_y = (8-@next_piece[0].length)/2
    render_piece @next_piece,13+center_x,2+center_y
    @args.outputs.labels << [905,650,"Next Piece",10,255,255,255,255]
  end

  def render
    render_background
    render_grid
    render_next_piece
    render_current_piece
    #render_score
  end

  def curr_piece_colliding
    for x in 0..@curr_piece.length-1 do
      for y in 0..@curr_piece[x].length-1 do
        if (@curr_piece[x][y] != 0)
          if (@curr_piece_y + y >= @grid_h-1)
            return true
          elsif @grid[@curr_piece_x+x][@curr_piece_y+y+1] != 0
            return true
          end
        end
      end
    end
    return false
  end

  def plant_curr_piece
    for x in 0..@curr_piece.length-1 do
      for y in 0..@curr_piece[x].length-1 do
        @grid[@curr_piece_x+x][@curr_piece_y+y] = @curr_piece[x][y] if @curr_piece[x][y]!=0
      end
    end
    @curr_piece_y = 0
    @curr_piece_x = 5
    select_next_piece
  end

  def select_next_piece
    @curr_piece = @next_piece
    X = rand(7)+1
    @next_piece = case X
    when 1 then [[0,X,0],[X,X,X]]
    when 2 then [[0,0,X],[X,X,X]]
    when 3 then [[X,X],[X,X]]
    when 4 then [[X,X,0],[0,X,X]]
    when 5 then [[0,X,X],[X,X,0]]
    when 6 then [[X,X,X,X]]
    when 7 then [[X,0,0],[X,X,X]]
    end

  end

  def rotate_piece_left
    if !curr_piece_colliding
      @curr_piece = @curr_piece.transpose.map(&:reverse)
      if @curr_piece_x - @curr_piece.length <= 0
        @curr_piece_x =  0
      end
      if @curr_piece_x + @curr_piece.length >= @grid_w
        @curr_piece_x = @grid_w - @curr_piece.length
      end
    end
  end

  def rotate_piece_right
    if !curr_piece_colliding
      @curr_piece = @curr_piece.transpose.reverse
      if @curr_piece_x - @curr_piece.length <= 0
        @curr_piece_x =  0
      end
      if @curr_piece_x + @curr_piece.length >= @grid_w
        @curr_piece_x = @grid_w - @curr_piece.length
      end
    end
  end

  def iterate
    #check input
    k = @args.inputs.keyboard
    k2 = @args.inputs.controller_one
    if k.key_down.left || k2.key_down.left
      @curr_piece_x-=1 if (@curr_piece_x > 0)
    end
    if k.key_down.right || k2.key_down.right
      @curr_piece_x+=1 if @curr_piece_x < @grid_w-@curr_piece.length
    end
    if k.key_down.down || k.key_held.down || k2.key_down.down || k2.key_held.down
      @next_move -= 10
    end
    if k.key_down.a || k2.key_down.a
      rotate_piece_left
    end
    if k.key_down.s || k2.key_down.b
      rotate_piece_right
    end
    #game state advancing
    @next_move -= 1
    if @next_move <= 0
      if curr_piece_colliding
        plant_curr_piece
      else
        @curr_piece_y += 1
      end
      @next_move = 30
    end
  end

  def tick
    iterate
    render
  end
end

def tick args
  args.state.game ||= TetrisGame.new args
  args.state.game.tick
end
