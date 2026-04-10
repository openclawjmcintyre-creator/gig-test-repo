# Snake Game Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a terminal-based Snake game in Python with score tracking, high score persistence, game over detection, Docker containerization, and GitHub repository setup.

**Architecture:** Clean Python implementation using curses for terminal rendering, modular file structure following React-inspired best practices (separation of concerns, pure functions), and Docker for consistent runtime environment.

**Tech Stack:** Python 3.12, curses, Docker (Alpine base)

---
## Project Structure

```
snake-game/
├── src/
│   ├── __init__.py
│   ├── game.py          # Core game logic
│   ├── snake.py         # Snake class
│   ├── food.py          # Food class
│   ├── score.py         # Score management
│   └── ui.py            # Curses UI rendering
├── tests/
│   ├── __init__.py
│   └── test_game.py
├── Dockerfile
├── requirements.txt
├── README.md
└── main.py              # Entry point
```

---
## Task 1: Create project structure and base files

**Files:**
- Create: `src/__init__.py`
- Create: `src/game.py`
- Create: `src/snake.py`
- Create: `src/food.py`
- Create: `src/score.py`
- Create: `src/ui.py`
- Create: `tests/__init__.py`

**Step 1: Create directory structure**

```bash
mkdir -p src tests
touch src/__init__.py tests/__init__.py
```

**Step 2: Create requirements.txt**

```bash
touch requirements.txt
```

**Step 3: Create main.py entry point**

```python
#!/usr/bin/env python3
"""Snake Game Entry Point"""
import curses
from src.game import SnakeGame

def main(stdscr):
    """Main game loop"""
    game = SnakeGame(stdscr)
    game.run()

if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        print("\nGame exited.")
```

**Step 4: Create README.md**

```markdown
# Snake Game

A terminal-based Snake game built with Python and curses.

## Features
- Classic Snake gameplay
- Score tracking with high score persistence
- Game over detection
- Responsive terminal UI

## Requirements
- Python 3.12+
- Terminal supporting curses

## Run
```bash
python main.py
```

## Test
```bash
pytest tests/ -v
```
```

**Step 5: Commit initial structure**

```bash
git add .
git commit -m "feat: initial project structure"
```

---
## Task 2: Implement Food class

**Files:**
- Create: `src/food.py`

**Step 1: Write food.py**

```python
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
```

**Step 2: Test food creation**

```python
# Add to tests/test_food.py
from src.food import Food

def test_food_generates_valid_position():
    snake_positions = [(5, 5), (5, 6), (5, 7)]
    food = Food(20, 40, snake_positions)
    pos = food.get_position()
    assert pos not in snake_positions
    assert 1 <= pos[0] < 18
    assert 1 <= pos[1] < 38
```

**Step 3: Run test**

```bash
pytest tests/test_food.py -v
```

**Step 4: Commit food class**

```bash
git add src/food.py tests/test_food.py
git commit -m "feat: add Food class"
```

---
## Task 3: Implement Snake class

**Files:**
- Create: `src/snake.py`

**Step 1: Write snake.py**

```python
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
```

**Step 2: Test snake movement**

```python
# Add to tests/test_snake.py
from src.snake import Snake, Direction

def test_snake_initialization():
    snake = Snake(10, 20)
    assert len(snake.get_body()) == 3
    assert snake.get_head() == (10, 20)

def test_snake_direction_change():
    snake = Snake(10, 20)
    snake.set_direction(Direction.UP)
    assert snake.direction == Direction.UP

def test_snake_cannot_reverse():
    snake = Snake(10, 20)
    snake.set_direction(Direction.LEFT)  # Currently RIGHT
    assert snake.direction == Direction.RIGHT  # Should stay

def test_snake_movement():
    snake = Snake(10, 20)
    old_head = snake.get_head()
    snake.move()
    new_head = snake.get_head()
    assert new_head == (10, 21)  # Moved right

def test_snake_collision():
    snake = Snake(10, 20)
    assert snake.check_collision(20, 40) == False
```

**Step 3: Run tests**

```bash
pytest tests/test_snake.py -v
```

**Step 4: Commit snake class**

```bash
git add src/snake.py tests/test_snake.py
git commit -m "feat: add Snake class with direction and movement"
```

---
## Task 4: Implement Score class

**Files:**
- Create: `src/score.py`

**Step 1: Write score.py**

```python
"""Score management for Snake Game"""
import json
import os


class Score:
    """Handles score tracking and persistence"""
    
    HIGH_SCORE_FILE = ".snake_highscore"
    
    def __init__(self):
        """Initialize score from file or default to 0"""
        self.score = 0
        self.high_score = self._load_high_score()
    
    def _load_high_score(self) -> int:
        """Load high score from file"""
        try:
            filepath = os.path.join(os.path.expanduser("~"), self.HIGH_SCORE_FILE)
            with open(filepath, "r") as f:
                return int(f.read().strip())
        except (FileNotFoundError, ValueError):
            return 0
    
    def _save_high_score(self) -> None:
        """Save high score to file"""
        filepath = os.path.join(os.path.expanduser("~"), self.HIGH_SCORE_FILE)
        with open(filepath, "w") as f:
            f.write(str(self.high_score))
    
    def add_point(self) -> None:
        """Add point and update high score"""
        self.score += 1
        if self.score > self.high_score:
            self.high_score = self.score
            self._save_high_score()
    
    def reset(self) -> None:
        """Reset score"""
        self.score = 0
    
    def get_score(self) -> int:
        """Return current score"""
        return self.score
    
    def get_high_score(self) -> int:
        """Return high score"""
        return self.high_score
```

**Step 2: Test score persistence**

```python
# Add to tests/test_score.py
from src.score import Score

def test_score_initialization():
    score = Score()
    assert score.get_score() == 0
    assert isinstance(score.get_high_score(), int)

def test_score_addition():
    score = Score()
    score.add_point()
    assert score.get_score() == 1

def test_high_score_update():
    score = Score()
    original_high = score.get_high_score()
    score.score = original_high + 10
    score.add_point()
    assert score.get_high_score() == original_high + 11
```

**Step 3: Run tests**

```bash
pytest tests/test_score.py -v
```

**Step 4: Commit score class**

```bash
git add src/score.py tests/test_score.py
git commit -m "feat: add Score class with persistence"
```

---
## Task 5: Implement UI rendering

**Files:**
- Create: `src/ui.py`

**Step 1: Write ui.py**

```python
"""UI rendering for Snake Game"""
import curses


class UI:
    """Handles all curses UI rendering"""
    
    def __init__(self, stdscr):
        """Initialize curses settings"""
        self.stdscr = stdscr
        self._setup_curses()
        self.max_y, self.max_x = self.stdscr.getmaxyx()
    
    def _setup_curses(self) -> None:
        """Configure curses settings"""
        curses.curs_set(0)  # Hide cursor
        self.stdscr.nodelay(True)  # Non-blocking input
        self.stdscr.timeout(100)  # 100ms input timeout
    
    def clear(self) -> None:
        """Clear screen"""
        self.stdscr.clear()
    
    def refresh(self) -> None:
        """Refresh screen"""
        self.stdscr.refresh()
    
    def draw_board(self, snake_positions: list, food_position: tuple, score: int, high_score: int) -> None:
        """Draw game board"""
        self.clear()
        
        # Draw border
        self.stdscr.attron(curses.color_pair(1))
        for x in range(self.max_x):
            self.stdscr.addch(0, x, "#")
            self.stdscr.addch(self.max_y - 1, x, "#")
        for y in range(self.max_y):
            self.stdscr.addch(y, 0, "#")
            self.stdscr.addch(y, self.max_x - 1, "#")
        self.stdscr.attroff(curses.color_pair(1))
        
        # Draw snake
        self.stdscr.attron(curses.color_pair(2))
        for pos in snake_positions:
            y, x = pos
            if 0 < y < self.max_y - 1 and 0 < x < self.max_x - 1:
                self.stdscr.addch(y, x, "O")
        self.stdscr.attroff(curses.color_pair(2))
        
        # Draw food
        self.stdscr.attron(curses.color_pair(3))
        if food_position:
            y, x = food_position
            if 0 < y < self.max_y - 1 and 0 < x < self.max_x - 1:
                self.stdscr.addch(y, x, "@")
        self.stdscr.attroff(curses.color_pair(3))
        
        # Draw score
        self.stdscr.addstr(0, self.max_x // 2 - 10, f"Score: {score:03d} | High: {high_score:03d}")
    
    def draw_game_over(self, score: int, high_score: int) -> None:
        """Draw game over screen"""
        self.clear()
        
        msg = "GAME OVER"
        y = self.max_y // 2
        x = (self.max_x - len(msg)) // 2
        self.stdscr.addstr(y, x, msg, curses.color_pair(4))
        
        score_msg = f"Final Score: {score}"
        x = (self.max_x - len(score_msg)) // 2
        self.stdscr.addstr(y + 1, x, score_msg)
        
        if score == high_score and score > 0:
            high_msg = "NEW HIGH SCORE!"
            x = (self.max_x - len(high_msg)) // 2
            self.stdscr.addstr(y + 2, x, high_msg, curses.color_pair(5))
        
        self.stdscr.addstr(y + 4, 2, "Press any key to return to menu...")
    
    def get_key(self) -> int:
        """Get keypress"""
        return self.stdscr.getch()
```

**Step 2: Test UI initialization**

```python
# Add to tests/test_ui.py
import curses
from src.ui import UI

def test_ui_initialization(stdscr):
    ui = UI(stdscr)
    assert ui.max_y > 0
    assert ui.max_x > 0

# Note: UI tests require curses wrapper, run manually
```

**Step 3: Commit UI class**

```bash
git add src/ui.py tests/test_ui.py
git commit -m "feat: add UI class for curses rendering"
```

---
## Task 6: Implement Game class

**Files:**
- Modify: `src/game.py`

**Step 1: Write game.py**

```python
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
```

**Step 2: Test game initialization**

```python
# Add to tests/test_game.py
import curses
from src.game import SnakeGame

def test_game_initialization(stdscr):
    game = SnakeGame(stdscr)
    assert game.running == True
    assert game.game_over == False
    assert len(game.snake.get_body()) == 3

# Note: Game tests require curses wrapper
```

**Step 3: Test entire game flow**

```bash
python main.py
# Play manually to verify
```

**Step 4: Commit game class**

```bash
git add src/game.py tests/test_game.py
git commit -m "feat: add SnakeGame class with full game loop"
```

---
## Task 7: Create Dockerfile

**Files:**
- Create: `Dockerfile`

**Step 1: Write Dockerfile**

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache ncurses-libs

# Copy files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
COPY main.py .

# Create non-root user
RUN adduser -D -g '' appuser
USER appuser

# Run game
CMD ["python", "main.py"]
```

**Step 2: Create requirements.txt with dependencies**

```txt
# No external dependencies - using only stdlib
```

**Step 3: Commit Docker files**

```bash
git add Dockerfile requirements.txt
git commit -m "chore: add Docker containerization"
```

---
## Task 8: Final cleanup and documentation

**Step 1: Update README with run instructions**

```markdown
# Snake Game

A terminal-based Snake game built with Python and curses.

## Features
- Classic Snake gameplay
- Score tracking with high score persistence (~/.snake_highscore)
- Game over detection
- Responsive terminal UI
- Docker support

## Requirements
- Python 3.12+
- Terminal supporting curses

## Run (Direct)
```bash
python main.py
```

## Run (Docker)
```bash
docker build -t snake-game .
docker run -it snake-game
```

## Controls
- Arrow keys or W/A/S/D to move
- Q to quit
- Space to pause

## Test
```bash
pytest tests/ -v
```
```

**Step 2: Add tests to requirements.txt for CI**

```txt
pytest>=7.0.0
```

**Step 3: Final commit**

```bash
git add .
git commit -m "docs: update README and add pytest"
```

---
## Task 9: Push to GitHub

**Step 1: Add remote and push**

```bash
git remote add origin https://github.com/openclawjmcintyre-creator/gig-test-repo.git
git branch -M main
git push -u origin main
```

**Step 2: Verify on GitHub**

Visit: https://github.com/openclawjmcintyre-creator/gig-test-repo

---
## Task 10: Test in Docker

**Step 1: Build Docker image**

```bash
docker build -t snake-game .
```

**Step 2: Run with Docker**

```bash
docker run -it --rm snake-game
```

**Note:** Docker with curses requires terminal allocation.

---
## Summary

**Files Created:**
- `src/__init__.py`
- `src/snake.py` - Snake class
- `src/food.py` - Food class
- `src/score.py` - Score class
- `src/ui.py` - UI rendering
- `src/game.py` - Game logic
- `tests/__init__.py`
- `tests/test_snake.py`
- `tests/test_food.py`
- `tests/test_score.py`
- `tests/test_ui.py`
- `tests/test_game.py`
- `Dockerfile`
- `requirements.txt`
- `main.py`
- `README.md`

**Run Game:**
```bash
python main.py
```

**Run Tests:**
```bash
pytest tests/ -v
```
