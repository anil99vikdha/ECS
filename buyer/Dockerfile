# Use official lightweight Python image
FROM python:3.11-slim

# Set a working directory inside the container
WORKDIR /app

# Copy only requirements first for efficient caching
COPY requirements.txt .

# Install Python dependencies without cache to keep image size small
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code into the container
COPY . .

# Create and switch to a non-root user for better security
RUN useradd --create-home appuser
USER appuser

# Expose the application port
EXPOSE 5000

# Set environment variable for Flask production mode
ENV FLASK_ENV=production

# Command to run the app with Gunicorn for production-grade hosting
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app", "--workers", "3", "--threads", "3"]