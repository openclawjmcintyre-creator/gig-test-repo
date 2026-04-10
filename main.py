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
