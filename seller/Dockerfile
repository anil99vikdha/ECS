# Use official lightweight Python image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy only requirements first for caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Use a non-root user for security
RUN useradd --create-home appuser
USER appuser

# Expose port (matches Flask default)
EXPOSE 5001

# Set environment variables (sensitive ones injected at runtime)
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=production

# Start the Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "app:app", "--workers", "3", "--threads", "3"]