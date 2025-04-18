# Use official Python base image
FROM python:3.11-slim

# Install tesseract and other dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all files
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your app runs on (update if not 5000)
EXPOSE 5000

# Run your app
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
