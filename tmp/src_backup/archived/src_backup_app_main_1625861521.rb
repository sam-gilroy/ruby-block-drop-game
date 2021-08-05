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
    @curr_piece = [[],[]]
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
  end

  def render_grid_border
    x=-1
    y=-1
    w = @grid_w+2
    h = @grid_h+2
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
    render_grid_border
  end

  def render_grid
    for x in 0..@grid_w-1 do
      for y in 0..@grid_h-1 do
        render_block x,y, @grid[x][y] if @grid[x][y]!=0
      end
    end
  end

  def render_current_piece
    for x in 0..@curr_piece.length-1 do
      for y in 0..@curr_piece[x].length-1 do
        render_block @curr_piece_x + x, @curr_piece_y + y,@curr_piece[x][y]  if @curr_piece[x][y] != 0
      end
    end
  end

  def render
    render_background
    render_grid
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
        @grid[@curr_piece_x+x][@curr_piece_y+y] = @curr_piece[x][y]
      end
    end
    @curr_piece_y = 0
    @curr_piece_x = 5
    select_next_piece
  end

  def select_next_piece
    X = rand(7)+1
    @curr_piece = case X
    when 1 then [[0,X,0],[X,X,X]]
    when 2 then [[0,0,X],[X,X,X]]
    when 3 then [[X,X],[X,X]]
    when 4 then [[X,X,0],[0,X,X]]
    when 5 then [[0,X,X],[X,X,0]]
    when 6 then [[X,X,X,X]]
    when 7 then [[X,0,0],[X,X,X]]
    end

  end

  def iterate
    #check input
    k = @args.inputs.keyboard
    k2 = @args.inputs.controller_one
    if k.key_down.left || k2.key_down.left
      @curr_piece_x-=1 if @curr_piece_x > 0
    end
    if k.key_down.right || k2.key_down.right
      @curr_piece_x+=1 if @curr_piece_x < @grid_w-@curr_piece.length
    end
    if k.key_down.down || k.key_held.down || k2.key_down.down || k2.key_held.down
      @next_move -= 10
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
