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
