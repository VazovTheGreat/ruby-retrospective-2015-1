def move(snake, directions)
  new_snake = snake.clone
  new_snake.shift
  grow(new_snake, directions)
end

def grow(snake, directions)
  new_snake = snake.clone
  new_head = [new_snake[-1][0] + directions[0],
              new_snake[-1][1] + directions[1]]
  new_snake.push(new_head)
  new_snake
end

def new_food(food, snake, dimensions)
  obstacles = food + snake
  x_coordinates = (0..dimensions[:width] - 1).to_a
  y_coordinates = (0..dimensions[:width] - 1).to_a
  whole_board = x_coordinates.product(y_coordinates)
  free_board = whole_board - obstacles
  free_board.sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = [snake[-1][0] + direction[0],snake[-1][1] + direction[1]]
  if snake.include?(next_position) or
      (next_position[0] < 0 or next_position[0] >= dimensions[:width]) or
      (next_position[1] < 0 or next_position[1] >= dimensions[:height])
    true
  else
    false
  end
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) and
      obstacle_ahead?(move(snake, direction), direction, dimensions)
end