def init args
  #background color
  args.outputs.solids << [0,0,1280,720,0,0,0]

  #game state variables
  args.state.score ||= 0
  args.state.game_over ||= false
  args.state.grid_w ||= 10
  args.state.grid_h ||= 20
  args.state.curr_block_x ||= 5
  args.state.curr_block_y ||= 0

  #grid building
  if args.state.grid.nil?
    args.state.grid = []
    for x in 0..args.state.grid_w-1 do
      for y in 0..args.state.grid_h-1 do
        args.state.grid[x][y] = 0
      end
    end
  end
end

def render args
end

def tick args
  init args
  render args
end
