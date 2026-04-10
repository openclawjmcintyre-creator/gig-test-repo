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
