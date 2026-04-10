"""Snake class for Snake Game"""
from enum import Enum


class Direction(Enum):
    """Game directions"""
    UP = (-1, 0)
    DOWN = (1, 0)
    LEFT = (0, -1)
    RIGHT = (0, 1)


class Snake:
    """Represents the snake in the game"""
    
    def __init__(self, start_y: int, start_x: int):
        """Initialize snake with starting position"""
        self.body = [(start_y, start_x), (start_y, start_x - 1), (start_y, start_x - 2)]
        self.direction = Direction.RIGHT
        self.grow_pending = False
    
    def get_head(self) -> tuple:
        """Return head position"""
        return self.body[0]
    
    def get_body(self) -> list:
        """Return entire snake body"""
        return self.body.copy()
    
    def set_direction(self, new_direction: Direction) -> None:
        """Set new direction (prevents 180-degree turns)"""
        opposite = {
            Direction.UP: Direction.DOWN,
            Direction.DOWN: Direction.UP,
            Direction.LEFT: Direction.RIGHT,
            Direction.RIGHT: Direction.LEFT
        }
        if new_direction != opposite.get(self.direction):
            self.direction = new_direction
    
    def move(self, grow: bool = False) -> bool:
        """Move snake forward, return True if collision"""
        head_y, head_x = self.get_head()
        dy, dx = self.direction.value
        new_head = (head_y + dy, head_x + dx)
        
        # Check if growing
        if grow:
            self.body = [new_head] + self.body
            return False
        
        # Move normally
        self.body = [new_head] + self.body[:-1]
        return False
    
    def check_collision(self, max_y: int, max_x: int) -> bool:
        """Check if snake hit wall or itself"""
        head_y, head_x = self.get_head()
        
        # Wall collision
        if head_y <= 0 or head_y >= max_y - 1:
            return True
        if head_x <= 0 or head_x >= max_x - 1:
            return True
        
        # Self collision
        if len(self.body) != len(set(self.body)):
            return True
        
        return False
