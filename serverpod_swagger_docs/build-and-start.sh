#!/bin/bash

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Build the production version
echo "Building production version..."
npm run build

# Start the production server
echo "Starting production server..."
npm start