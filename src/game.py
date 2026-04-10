"""Core game logic for Snake Game"""
import curses
from src.snake import Snake, Direction
from src.food import Food
from src.score import Score
from src.ui import UI


class SnakeGame:
    """Main game class"""
    
    def __init__(self, stdscr):
        """Initialize game"""
        self.stdscr = stdscr
        self.ui = UI(stdscr)
        self.snake = Snake(self.ui.max_y // 2, self.ui.max_x // 2)
        self.food = Food(self.ui.max_y, self.ui.max_x, self.snake.get_body())
        self.score = Score()
        self.running = True
        self.game_over = False
        self.speed = 100  # ms between frames
    
    def _handle_input(self) -> None:
        """Handle user input"""
        key = self.ui.get_key()
        if key == -1:
            return
        
        direction_map = {
            ord('w'): Direction.UP,
            ord('s'): Direction.DOWN,
            ord('a'): Direction.LEFT,
            ord('d'): Direction.RIGHT,
            ord(' '): None,  # Pause
            curses.KEY_UP: Direction.UP,
            curses.KEY_DOWN: Direction.DOWN,
            curses.KEY_LEFT: Direction.LEFT,
            curses.KEY_RIGHT: Direction.RIGHT,
            ord('q'): None  # Quit
        }
        
        if key == ord('q'):
            self.running = False
            return
        
        if key in direction_map and direction_map[key] is not None:
            self.snake.set_direction(direction_map[key])
    
    def _update(self) -> None:
        """Update game state"""
        if self.game_over:
            return
        
        # Move snake
        self.snake.move()
        
        # Check collisions
        if self.snake.check_collision(self.ui.max_y, self.ui.max_x):
            self.game_over = True
            return
        
        # Check food collision
        if self.snake.get_head() == self.food.get_position():
            self.score.add_point()
            self.food.respawn(self.snake.get_body())
            # Grow snake next move
            self.snake.body = [self.snake.get_head()] + self.snake.body
    
    def _draw(self) -> None:
        """Draw game"""
        if self.game_over:
            self.ui.draw_game_over(self.score.get_score(), self.score.get_high_score())
        else:
            self.ui.draw_board(
                self.snake.get_body(),
                self.food.get_position(),
                self.score.get_score(),
                self.score.get_high_score()
            )
        self.ui.refresh()
    
    def run(self) -> None:
        """Main game loop"""
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_GREEN, -1)  # Border
        curses.init_pair(2, curses.COLOR_YELLOW, -1)  # Snake
        curses.init_pair(3, curses.COLOR_RED, -1)     # Food
        curses.init_pair(4, curses.COLOR_RED, -1)     # Game over
        curses.init_pair(5, curses.COLOR_GREEN, -1)   # High score
        
        while self.running:
            if self.game_over:
                self.ui.get_key()  # Wait for key
                self.running = False
                continue
            
            self._handle_input()
            self._update()
            self._draw()
        
        self.score.reset()
