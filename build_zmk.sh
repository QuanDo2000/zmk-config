#!/bin/bash

# Define your paths
WORKSPACE="/home/quando/documents/zmk"
CONFIG="/workspaces/zmk-config/config"

# Get keyboard argument (default: all)
KEYBOARD="${1:-all}"

echo "🚀 Starting Dev Container..."
devcontainer up --workspace-folder "$WORKSPACE"

# Function to run the build command inside the container
build_side() {
  local side=$1     # 'left' or 'right'
  local board=$2    # board name like 'glove80_lh' or 'go60_lh'
  local keyboard=$3 # keyboard name for output like 'glove80' or 'go60'

  echo "📦 Building $side half of $keyboard ($board)..."

  devcontainer exec --workspace-folder "$WORKSPACE" \
    sh -c "cd /workspaces/zmk/app && west build -p -d ../build/$keyboard/$side -b $board -- -DZMK_CONFIG='$CONFIG'"
}

# Function to copy files for a keyboard
copy_keyboard_files() {
  local keyboard=$1
  local CONTAINER_ID=$2
  
  echo "📥 Copying $keyboard UF2 files to output folder..."
  docker cp "$CONTAINER_ID:/workspaces/zmk/build/$keyboard/left/zephyr/zmk.uf2" ./output/${keyboard}_left.uf2
  docker cp "$CONTAINER_ID:/workspaces/zmk/build/$keyboard/right/zephyr/zmk.uf2" ./output/${keyboard}_right.uf2
}

# Create output directory if it doesn't exist
mkdir -p output

# Build based on keyboard argument
if [ "$KEYBOARD" = "all" ] || [ "$KEYBOARD" = "glove80" ]; then
  build_side "left" "glove80_lh" "glove80"
  build_side "right" "glove80_rh" "glove80"
fi

if [ "$KEYBOARD" = "all" ] || [ "$KEYBOARD" = "go60" ]; then
  build_side "left" "go60_lh" "go60"
  build_side "right" "go60_rh" "go60"
fi

# Get container ID for copying files
CONTAINER_ID=$(docker ps -q -f "label=devcontainer.local_folder=$WORKSPACE")

# Copy files based on keyboard argument
if [ "$KEYBOARD" = "all" ] || [ "$KEYBOARD" = "glove80" ]; then
  copy_keyboard_files "glove80" "$CONTAINER_ID"
fi

if [ "$KEYBOARD" = "all" ] || [ "$KEYBOARD" = "go60" ]; then
  copy_keyboard_files "go60" "$CONTAINER_ID"
fi

echo "✅ Build complete! Files are in the output/ directory."
