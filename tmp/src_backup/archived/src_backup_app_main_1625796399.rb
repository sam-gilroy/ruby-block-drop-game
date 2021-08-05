def init args
  args.outputs.solids << [0,0,1280,720,0,0,0] #background color
  args.state.score ||= 0
  args.state.game_over ||= false
  args.state.grid_w ||= 10
  args.state.grid_h ||= 20
end

def tick args
  init args
end
