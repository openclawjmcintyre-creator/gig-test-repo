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
