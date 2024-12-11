#!/bin/bash


# # Function to determine Python source
# check_python_source() {
#   PYTHON_BIN=$(command -v python3)

#   if [[ "$PYTHON_BIN" == *".pyenv"* ]]; then
#     echo "python3 is a Pyenv Python: $PYTHON_BIN"
#     echo "Switching to the System Python... to access the Modeller package."
#     pyenv shell system
#     echo "System Python3: $(command -v python3)"
#   fi
# }

# check_python_source

# Step 1: Find the Modeller package path
MODELLER_PATH=$(/usr/bin/python3 -c "import modeller; print(modeller.__file__)" 2>/dev/null)

# Check if the Modeller package was found
if [ -z "$MODELLER_PATH" ]; then
  echo "Error: Could not find the 'modeller' package using $(command -v python3)"
  exit 1
fi

# Remove the __init__.py or similar file name to get the directory path
MODELLER_DIR=$(dirname "$MODELLER_PATH")

echo "Found Modeller package at: $MODELLER_DIR"

# Step 2: Locate the Poetry-managed site-packages folder
SITE_PACKAGES_FOLDER="$(ls -d $(poetry env info -p)/lib/python*/site-packages/)"


# Check if the site-packages folder was found
if [ -z "$SITE_PACKAGES_FOLDER" ]; then
  echo "Error: Could not find the Poetry-managed site-packages folder."
  exit 1
fi

PROJECT_PTH="${SITE_PACKAGES_FOLDER}project_dir.pth"

# Check if the project_dir.pth file exists; create it if it doesn't
if [ ! -f "$PROJECT_PTH" ]; then
  echo "Creating project_dir.pth file at: $PROJECT_PTH"
  touch "$PROJECT_PTH"
fi

# Step 3: Append the Modeller directory path to the .pth file
if grep -qx "$MODELLER_DIR" "$PROJECT_PTH"; then
  echo "The Modeller path is already present in $PROJECT_PTH."
else
  echo "Adding Modeller path to $PROJECT_PTH..."
  echo "$MODELLER_DIR" >> "$PROJECT_PTH"
  echo "Modeller path added successfully."
fi

# Final message
echo "Completed setup. Modeller should now be accessible in your Poetry environment."
