"""Food class for Snake Game"""
import random


class Food:
    """Represents food in the game"""
    
    def __init__(self, max_y: int, max_x: int, snake_positions: list):
        """Initialize food at a random position not occupied by snake"""
        self.max_y = max_y
        self.max_x = max_x
        self.position = self._generate_position(snake_positions)
    
    def _generate_position(self, snake_positions: list) -> tuple:
        """Generate random position not on snake"""
        while True:
            y = random.randint(1, self.max_y - 2)
            x = random.randint(1, self.max_x - 2)
            if (y, x) not in snake_positions:
                return (y, x)
    
    def get_position(self) -> tuple:
        """Return current food position"""
        return self.position
    
    def respawn(self, snake_positions: list) -> None:
        """Respawn food at new position"""
        self.position = self._generate_position(snake_positions)
