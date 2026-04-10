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
