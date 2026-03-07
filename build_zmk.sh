#!/bin/bash

# Define your paths
WORKSPACE="/home/quando/documents/zmk"
CONFIG="/workspaces/zmk-config/config"

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

# Run builds for all keyboards
build_side "left" "glove80_lh" "glove80"
build_side "right" "glove80_rh" "glove80"
build_side "left" "go60_lh" "go60"
build_side "right" "go60_rh" "go60"

# Copy the files out to output folder
CONTAINER_ID=$(docker ps -q -f "label=devcontainer.local_folder=$WORKSPACE")

# Create output directory if it doesn't exist
mkdir -p output

echo "📥 Copying UF2 files to output folder..."
docker cp "$CONTAINER_ID:/workspaces/zmk/build/glove80/left/zephyr/zmk.uf2" ./output/glove80_left.uf2
docker cp "$CONTAINER_ID:/workspaces/zmk/build/glove80/right/zephyr/zmk.uf2" ./output/glove80_right.uf2
docker cp "$CONTAINER_ID:/workspaces/zmk/build/go60/left/zephyr/zmk.uf2" ./output/go60_left.uf2
docker cp "$CONTAINER_ID:/workspaces/zmk/build/go60/right/zephyr/zmk.uf2" ./output/go60_right.uf2

echo "✅ Build complete! Files are in the output/ directory."
