class TetrisGame
  def initialize args
    @args = args
    #game state variables
    @score = 0
    @gameover = false
    @grid_w = 10
    @grid_h = 20
    @curr_block_x = 5
    @curr_block_y = 0

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
  def render_block x,y
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - (@grid_h-1 * boxsize)) / 2
    @args.outputs.solids << [grid_x + (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,255,0,0,255]
  end

  def render_background
    @args.outputs.solids << [0,0,1280,720,0,0,0]
  end

  def render_grid
    for x in 0..@grid_w-1 do
      for y in 0..@grid_h-1 do
        render_block x,y
      end
    end
  end

  def render
    render_background
    render_grid
    #render_score
  end

  def tick
    render
  end
end

def tick args
  args.state.game ||= TetrisGame.new args
  args.state.game.tick
end
