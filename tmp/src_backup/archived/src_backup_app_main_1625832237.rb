def init args
  #game state variables
  args.state.score ||= 0
  args.state.gameover ||= false
  args.state.grid_w ||= 10
  args.state.grid_h ||= 20
  args.state.curr_block_x ||= 5
  args.state.curr_block_y ||= 0

  #grid building
  if args.state.grid.nil?
    args.state.grid = []
    for x in 0..args.state.grid_w-1 do
      args.state.grid[x] = []
      for y in 0..args.state.grid_h-1 do
        args.state.grid[x][y] = 0
      end
    end
  end
end

#x and y are positions on grid
def render_block args,x,y
  boxsize = 30
  grid_x = 0
  grid_y = 0

  args.outputs.solids << [grid_x = (x*boxsize), (720-grid_y) - (y*boxsize),boxsize,boxsize,255,0,0,255]
end

def render_background args
  args.outputs.solids << [0,0,1280,720,0,0,0]
end

def render_grid args
  for x in 0..args.state.grid_w-1 do
    for y in 0..args.state.grid_h-1 do
      render_block args,x,y
    end
  end
end

def render args
  render_background args
  render_grid args
  #render_score
end

def tick args
  init args
  render args
end
