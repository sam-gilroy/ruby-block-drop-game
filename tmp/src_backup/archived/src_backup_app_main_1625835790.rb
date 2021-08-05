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
    @curr_piece = [[1,1],[1,1]]

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
  def render_block x,y,r,g,b,a=255
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h-2) * boxsize)) / 2
    @args.outputs.solids << [grid_x + (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,r,g,b,a]
  end

  def render_grid_border
    x=-1
    y=-1
    w = @grid_w+2
    h = @grid_h+2
    color = [0, 0, 255]

    for i in x..(x+w)-1 do
      render_block i, y, *color
      render_block i, (y+h)-1, *color
    end

    for i in y..(y+h)-1 do
      render_block x, i, *color
      render_block (x+w)-1, i, *color
    end
  end

  def render_background
    @args.outputs.solids << [0,0,1280,720,0,0,0]
    render_grid_border
  end

  def render_grid
    for x in 0..@grid_w-1 do
      for y in 0..@grid_h-1 do
        render_block x,y, 255, 0, 0 if @grid[x][y]!=0
      end
    end
  end

  def render_current_piece
    color = [255, 0, 0]
    for x in 0..@curr_piece.length-1 do
      for y in 0..@curr_piece[x].length-1 do
        render_block @curr_piece_x + x, @curr_piece_y + y, *color if @curr_piece[x][y] != 0
      end
    end
  end

  def render
    render_background
    render_grid
    render_current_piece
    #render_score
  end

  def iterate
    @next_move -= 1
    if @next_move <= 0
      @curr_piece_y += 1
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
