#!/bin/bash

# wget -qO MDdesktop2204.sh 'https://raw.githubusercontent.com/MachoDrone/MDdesktop2204/main/MDdesktop2204.sh' && sudo bash MDdesktop2204.sh.sh


# Define variables
AUTOSTART_DIR=~/.config/autostart
TILE_SCRIPT=/home/$USER/tile_terminals.sh

# Function to check and create .desktop entry if not exists
create_desktop_entry() {
    local script_name=$1
    local script_path=$2

    local desktop_entry="$AUTOSTART_DIR/$script_name.desktop"

    if [ ! -f "$desktop_entry" ]; then
        echo "Creating $desktop_entry..."
        cat << EOF > "$desktop_entry"
[Desktop Entry]
Type=Application
Exec=gnome-terminal --title="$script_name" -- bash -c "$script_path; exec bash"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=$script_name
EOF
    else
        echo "$desktop_entry already exists, skipping..."
    fi
}

# Ensure the autostart directory exists
if [ ! -d "$AUTOSTART_DIR" ]; then
    echo "Creating autostart directory $AUTOSTART_DIR..."
    mkdir -p "$AUTOSTART_DIR"
else
    echo "Autostart directory $AUTOSTART_DIR already exists."
fi

# Create .desktop entries for the scripts if they don't already exist
for script in glances.sh tpsview.sh startnode.sh nvitop.sh; do
    create_desktop_entry "$script" "/home/$USER/$script"
done

# Create the tiling script if it doesn't already exist
if [ ! -f "$TILE_SCRIPT" ]; then
    echo "Creating tiling script $TILE_SCRIPT..."
    cat << 'EOF' > "$TILE_SCRIPT"
#!/bin/bash

# Give time for the terminal windows to open
sleep 10

# Get the window IDs of the terminal windows
TERMINAL_IDS=$(wmctrl -l | grep "$USER" | grep "Terminal" | awk '{print $1}')

# Tile the windows in a 2x2 grid
COUNTER=0
for ID in $TERMINAL_IDS; do
    if [ $COUNTER -eq 0 ]; then
        wmctrl -ir $ID -e 0,0,0,960,540
    elif [ $COUNTER -eq 1 ]; then
        wmctrl -ir $ID -e 0,960,0,960,540
    elif [ $COUNTER -eq 2 ]; then
        wmctrl -ir $ID -e 0,0,540,960,540
    elif [ $COUNTER -eq 3 ]; then
        wmctrl -ir $ID -e 0,960,540,960,540
    fi
    COUNTER=$((COUNTER + 1))
done
EOF
    chmod +x "$TILE_SCRIPT"
else
    echo "Tiling script $TILE_SCRIPT already exists, skipping..."
fi

# Create a .desktop entry for the tiling script if it doesn't already exist
if [ ! -f "$AUTOSTART_DIR/tile_terminals.desktop" ]; then
    echo "Creating $AUTOSTART_DIR/tile_terminals.desktop..."
    cat << EOF > "$AUTOSTART_DIR/tile_terminals.desktop"
[Desktop Entry]
Type=Application
Exec=$TILE_SCRIPT
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Tile Terminals
EOF
else
    echo "$AUTOSTART_DIR/tile_terminals.desktop already exists, skipping..."
fi

echo "Setup complete. The scripts will run and be tiled at startup."
