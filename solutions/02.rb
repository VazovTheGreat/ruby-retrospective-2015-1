def move(snake, directions)
  new_snake = grow(snake, directions).drop(1)
end

def grow(snake, directions)
  new_snake = snake.dup
  new_snake + [create_new_head(snake, directions)]
end

def new_food(food, snake, dimensions)
  obstacles = food + snake
  xs, ys = (0..dimensions[:width] - 1).to_a, (0..dimensions[:height] - 1).to_a
  whole_board = xs.product(ys)
  (whole_board - obstacles).sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = create_new_head(snake, direction)
  if snake.include?(next_position) or wall_ahead?(next_position, dimensions)
    true
  else
    false
  end
end

def wall_ahead?(head, dimensions)
  (head[0] < 0 or head[0] >= dimensions[:width]) or
  (head[1] < 0 or head[1] >= dimensions[:height])
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
      obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def create_new_head(snake, direction)
  [snake[-1][0] + direction[0],snake[-1][1] + direction[1]]
end
