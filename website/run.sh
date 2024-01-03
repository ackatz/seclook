#!/bin/sh

# Start uvicorn in the background
uvicorn app.main:app --host 0.0.0.0 --port 8080