#!/bin/bash

# MasterCraft - Minecraft Server Management System
# Author: Assistant
# Version: 1.1

# Configuration
MINECRAFT_DIR="$HOME/minecraft"
BACKUPS_DIR="$MINECRAFT_DIR/backups"
SERVERS_DIR="$MINECRAFT_DIR/servers"
DOWNLOADS_DIR="$MINECRAFT_DIR/downloads"
DATAPACKS_DIR="$MINECRAFT_DIR/datapacks"
TMUX_SESSION="minecraft-server"
MEMORY="6G"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Title
show_title() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗  ██████╗██████╗  █████╗ ███████╗████████╗
    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝██║     ██████╔╝███████║█████╗     ██║   
    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║     ██╔══██╗██╔══██║██╔══╝     ██║   
    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║╚██████╗██║  ██║██║  ██║██║        ██║   
    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   
EOF
    echo -e "${WHITE}                              Minecraft Server Management System v1.1${NC}"
    echo -e "${PURPLE}                                    Created for world-focused management${NC}\n"
}

# Initialize directory structure
init_directories() {
    mkdir -p "$MINECRAFT_DIR"
    mkdir -p "$BACKUPS_DIR"
    mkdir -p "$SERVERS_DIR"
    mkdir -p "$DOWNLOADS_DIR"
    mkdir -p "$DATAPACKS_DIR"
    
    # Create datapacks info file if it doesn't exist
    if [[ ! -f "$DATAPACKS_DIR/README.txt" ]]; then
        echo "Place your datapacks in this directory." > "$DATAPACKS_DIR/README.txt"
        echo "They will be automatically copied to new worlds." >> "$DATAPACKS_DIR/README.txt"
    fi
}

# Create default ops.json (server admins)
create_ops() {
    local server_path="$1"
    # Create empty ops file - users can add themselves via console or edit this file
    cat > "$server_path/ops.json" << 'EOF'
[]
EOF
}

# Create default whitelist.json
create_whitelist() {
    local server_path="$1"
    # Create empty whitelist - users can add players via console or edit this file
    cat > "$server_path/whitelist.json" << 'EOF'
[]
EOF
}'EOF'
[
  {
    "uuid": "495af3a5-12d2-49cf-9bac-c713a673adae",
    "name": "NutellaSrK"
  },
  {
    "uuid": "5e019b2d-df8f-4b79-868c-d85be3d13093",
    "name": "RapBoyMeh"
  },
  {
    "uuid": "6d4fc510-410c-4c3a-957b-545d98c2d654",
    "name": "Daydaro"
  }
]
EOF
}

# Create default server.properties
create_server_properties() {
    local server_path="$1"
    local seed="$2"
    cat > "$server_path/server.properties" << EOF
#Minecraft server properties
#$(date)
enable-jmx-monitoring=false
rcon.port=25575
level-seed=${seed}
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=A Minecraft Server
query.port=25565
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=true
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
debug=false
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
EOF
}

# Create EULA
create_eula() {
    local server_path="$1"
    cat > "$server_path/eula.txt" << EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#$(date)
eula=true
EOF
}

# Download server JAR based on type
download_server_jar() {
    local server_type="$1"
    local server_path="$2"
    
    echo -e "${YELLOW}Downloading $server_type server JAR...${NC}"
    
    case "$server_type" in
        "vanilla")
            # Get latest release version and proper download URL using wget
            echo -e "${YELLOW}Getting latest Minecraft version info...${NC}"
            local manifest_url="https://launchermeta.mojang.com/mc/game/version_manifest.json"
            local temp_manifest="/tmp/mc_manifest.json"
            
            if ! wget -q -O "$temp_manifest" "$manifest_url"; then
                echo -e "${RED}Failed to download version manifest!${NC}"
                return 1
            fi
            
            local version=$(jq -r '.latest.release' "$temp_manifest")
            echo -e "${YELLOW}Latest version: $version${NC}"
            
            local version_url=$(jq -r ".versions[] | select(.id==\"$version\") | .url" "$temp_manifest")
            echo -e "${YELLOW}Getting version details...${NC}"
            
            local temp_version="/tmp/mc_version.json"
            if ! wget -q -O "$temp_version" "$version_url"; then
                echo -e "${RED}Failed to download version details!${NC}"
                rm -f "$temp_manifest"
                return 1
            fi
            
            local download_url=$(jq -r '.downloads.server.url' "$temp_version")
            echo -e "${YELLOW}Download URL: $download_url${NC}"
            
            # Clean up temp files
            rm -f "$temp_manifest" "$temp_version"
            
            if [[ "$download_url" == "null" || -z "$download_url" ]]; then
                echo -e "${RED}Failed to get download URL for Vanilla server!${NC}"
                return 1
            fi
            
            echo -e "${YELLOW}Downloading Vanilla server JAR...${NC}"
            if wget -O "$server_path/server.jar" "$download_url"; then
                echo -e "${GREEN}Vanilla server downloaded successfully!${NC}"
            else
                echo -e "${RED}Failed to download Vanilla server JAR!${NC}"
                return 1
            fi
            ;;
        "paper")
            # Get latest Paper version using wget
            echo -e "${YELLOW}Getting latest Paper version...${NC}"
            local temp_paper="/tmp/paper_versions.json"
            
            if ! wget -q -O "$temp_paper" "https://api.papermc.io/v2/projects/paper"; then
                echo -e "${RED}Failed to get Paper versions!${NC}"
                return 1
            fi
            
            local version=$(jq -r '.versions[-1]' "$temp_paper")
            echo -e "${YELLOW}Latest Paper version: $version${NC}"
            
            local temp_builds="/tmp/paper_builds.json"
            if ! wget -q -O "$temp_builds" "https://api.papermc.io/v2/projects/paper/versions/$version"; then
                echo -e "${RED}Failed to get Paper builds!${NC}"
                rm -f "$temp_paper"
                return 1
            fi
            
            local build=$(jq -r '.builds[-1]' "$temp_builds")
            echo -e "${YELLOW}Latest build: $build${NC}"
            
            # Clean up temp files
            rm -f "$temp_paper" "$temp_builds"
            
            local download_url="https://api.papermc.io/v2/projects/paper/versions/$version/builds/$build/downloads/paper-$version-$build.jar"
            echo -e "${YELLOW}Downloading Paper server JAR...${NC}"
            if wget -O "$server_path/server.jar" "$download_url"; then
                echo -e "${GREEN}Paper server downloaded successfully!${NC}"
            else
                echo -e "${RED}Failed to download Paper server JAR!${NC}"
                return 1
            fi
            ;;
        "spigot")
            echo -e "${RED}Spigot requires manual compilation. Please visit https://www.spigotmc.org/wiki/buildtools/${NC}"
            echo -e "${YELLOW}For now, placing a placeholder. Replace server.jar with your compiled Spigot JAR.${NC}"
            touch "$server_path/server.jar"
            ;;
        "fabric")
            # Get latest Fabric installer using wget
            echo -e "${YELLOW}Getting latest Minecraft version for Fabric...${NC}"
            local temp_manifest="/tmp/mc_manifest.json"
            
            if ! wget -q -O "$temp_manifest" "https://launchermeta.mojang.com/mc/game/version_manifest.json"; then
                echo -e "${RED}Failed to get Minecraft versions!${NC}"
                return 1
            fi
            
            local mc_version=$(jq -r '.latest.release' "$temp_manifest")
            rm -f "$temp_manifest"
            echo -e "${YELLOW}Using Minecraft version: $mc_version${NC}"
            
            local installer_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.0/fabric-installer-1.0.0.jar"
            echo -e "${YELLOW}Downloading Fabric installer...${NC}"
            if ! wget -O "$DOWNLOADS_DIR/fabric-installer.jar" "$installer_url"; then
                echo -e "${RED}Failed to download Fabric installer!${NC}"
                return 1
            fi
            
            echo -e "${YELLOW}Installing Fabric server...${NC}"
            # Install Fabric server
            if java -jar "$DOWNLOADS_DIR/fabric-installer.jar" server -dir "$server_path" -mcversion "$mc_version" -downloadMinecraft; then
                echo -e "${GREEN}Fabric server installed successfully!${NC}"
            else
                echo -e "${RED}Failed to install Fabric server!${NC}"
                return 1
            fi
            ;;
    esac
    
    if [[ -f "$server_path/server.jar" ]] || [[ -f "$server_path/fabric-server-launch.jar" ]]; then
        echo -e "${GREEN}Server JAR downloaded successfully!${NC}"
    else
        echo -e "${RED}Failed to download server JAR!${NC}"
        return 1
    fi
}

# Copy datapacks to world
copy_datapacks() {
    local world_path="$1"
    local datapacks_world_dir="$world_path/datapacks"
    
    if [[ -d "$DATAPACKS_DIR" ]] && [[ "$(ls -A "$DATAPACKS_DIR")" ]]; then
        echo -e "${YELLOW}Copying datapacks...${NC}"
        mkdir -p "$datapacks_world_dir"
        cp -r "$DATAPACKS_DIR"/*.* "$datapacks_world_dir/" 2>/dev/null || true
        echo -e "${GREEN}Datapacks copied successfully!${NC}"
    fi
}

# Create new server
create_server() {
    show_title
    echo -e "${WHITE}=== Create New Server ===${NC}\n"
    
    read -p "Enter world name: " world_name
    if [[ -z "$world_name" ]]; then
        echo -e "${RED}World name cannot be empty!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Sanitize world name
    world_name=$(echo "$world_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local server_path="$SERVERS_DIR/$world_name"
    
    if [[ -d "$server_path" ]]; then
        echo -e "${RED}Server with name '$world_name' already exists!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Get seed (optional)
    echo -e "\n${WHITE}World Seed (optional):${NC}"
    read -p "Enter seed (leave empty for random): " seed
    
    echo -e "\n${WHITE}Select server type:${NC}"
    echo -e "${CYAN}1)${NC} Vanilla"
    echo -e "${CYAN}2)${NC} Paper"
    echo -e "${CYAN}3)${NC} Spigot"
    echo -e "${CYAN}4)${NC} Fabric"
    echo -e "${CYAN}5)${NC} Cancel"
    
    read -p "Choose option [1-5]: " server_choice
    
    local server_type
    case "$server_choice" in
        1) server_type="vanilla" ;;
        2) server_type="paper" ;;
        3) server_type="spigot" ;;
        4) server_type="fabric" ;;
        5) return ;;
        *) echo -e "${RED}Invalid choice!${NC}"; read -p "Press Enter to continue..."; return ;;
    esac
    
    echo -e "\n${YELLOW}Creating server directory...${NC}"
    mkdir -p "$server_path"
    
    # Download server JAR
    if ! download_server_jar "$server_type" "$server_path"; then
        echo -e "${RED}Failed to create server!${NC}"
        rm -rf "$server_path"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Create server files
    echo -e "${YELLOW}Creating server configuration files...${NC}"
    create_eula "$server_path"
    create_server_properties "$server_path" "$seed"
    create_whitelist "$server_path"
    create_ops "$server_path"
    
    # Create server type file for reference
    echo "$server_type" > "$server_path/.server_type"
    
    # Store seed info
    if [[ -n "$seed" ]]; then
        echo "$seed" > "$server_path/.seed"
        echo -e "${GREEN}Server '$world_name' ($server_type) created with seed: $seed${NC}"
    else
        echo -e "${GREEN}Server '$world_name' ($server_type) created with random seed${NC}"
    fi
    
    echo -e "${YELLOW}You can now start it from the main menu.${NC}"
    read -p "Press Enter to continue..."
}

# List available servers
list_servers() {
    local servers=($(find "$SERVERS_DIR" -maxdepth 1 -type d -not -path "$SERVERS_DIR" | sort))
    if [[ ${#servers[@]} -eq 0 ]]; then
        echo -e "${RED}No servers found!${NC}"
        return 1
    fi
    
    echo -e "${WHITE}Available servers:${NC}"
    for i in "${!servers[@]}"; do
        local server_name=$(basename "${servers[$i]}")
        local server_type="unknown"
        local seed_info=""
        
        if [[ -f "${servers[$i]}/.server_type" ]]; then
            server_type=$(cat "${servers[$i]}/.server_type")
        fi
        
        if [[ -f "${servers[$i]}/.seed" ]]; then
            local seed=$(cat "${servers[$i]}/.seed")
            seed_info=" ${YELLOW}[Seed: $seed]${NC}"
        fi
        
        echo -e "${CYAN}$((i+1)))${NC} $server_name ${PURPLE}($server_type)${NC}$seed_info"
    done
    
    return 0
}

# Start server
start_server() {
    show_title
    echo -e "${WHITE}=== Start Server ===${NC}\n"
    
    if ! list_servers; then
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter server number to start: " server_num
    
    local servers=($(find "$SERVERS_DIR" -maxdepth 1 -type d -not -path "$SERVERS_DIR" | sort))
    
    if [[ ! "$server_num" =~ ^[0-9]+$ ]] || [[ "$server_num" -lt 1 ]] || [[ "$server_num" -gt ${#servers[@]} ]]; then
        echo -e "${RED}Invalid server number!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local server_path="${servers[$((server_num-1))]}"
    local server_name=$(basename "$server_path")
    
    # Check if tmux session already exists
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${YELLOW}A server is already running. Stopping it first...${NC}"
        stop_server_silent
        sleep 2
    fi
    
    # Determine server JAR to use
    local server_jar="server.jar"
    if [[ -f "$server_path/fabric-server-launch.jar" ]]; then
        server_jar="fabric-server-launch.jar"
    fi
    
    echo -e "${YELLOW}Starting server '$server_name'...${NC}"
    
    # Start server in tmux session
    cd "$server_path"
    tmux new-session -d -s "$TMUX_SESSION" -c "$server_path" "java -Xmx$MEMORY -Xms$MEMORY -jar $server_jar nogui"
    
    sleep 3
    
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${GREEN}Server started successfully!${NC}"
        echo -e "${WHITE}Use 'tmux attach -t $TMUX_SESSION' to view the server console${NC}"
        echo -e "${WHITE}Or use the 'Attach to Console' option from the main menu${NC}"
        
        # Copy datapacks when world is created
        local world_path="$server_path/world"
        if [[ ! -d "$world_path" ]]; then
            echo -e "${YELLOW}Waiting for world generation...${NC}"
            while [[ ! -d "$world_path" ]]; do
                sleep 2
            done
            sleep 5  # Give it a moment to fully create
            copy_datapacks "$world_path"
        fi
    else
        echo -e "${RED}Failed to start server!${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Stop server with backup
stop_server() {
    show_title
    echo -e "${WHITE}=== Stop Server ===${NC}\n"
    
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${RED}No server is currently running!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}Stopping server and creating backup...${NC}"
    
    # Send stop command
    tmux send-keys -t "$TMUX_SESSION" "say Server shutting down in 10 seconds for backup..." C-m
    sleep 2
    tmux send-keys -t "$TMUX_SESSION" "save-all" C-m
    sleep 3
    tmux send-keys -t "$TMUX_SESSION" "save-off" C-m
    sleep 2
    
    # Find current server directory
    local current_dir=$(tmux display-message -t "$TMUX_SESSION" -p "#{pane_current_path}")
    local server_name=$(basename "$current_dir")
    
    # Create backup
    create_backup "$current_dir" "$server_name"
    
    # Stop the server
    tmux send-keys -t "$TMUX_SESSION" "stop" C-m
    
    # Wait for server to stop
    local count=0
    while tmux has-session -t "$TMUX_SESSION" 2>/dev/null && [[ $count -lt 30 ]]; do
        sleep 1
        ((count++))
    done
    
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${YELLOW}Server taking too long to stop, killing session...${NC}"
        tmux kill-session -t "$TMUX_SESSION"
    fi
    
    echo -e "${GREEN}Server stopped successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Silent stop (used internally)
stop_server_silent() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux send-keys -t "$TMUX_SESSION" "save-all" C-m
        sleep 2
        tmux send-keys -t "$TMUX_SESSION" "stop" C-m
        sleep 5
        tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true
    fi
}

# Create backup
create_backup() {
    local server_path="$1"
    local server_name="$2"
    local backup_name="${server_name}_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUPS_DIR/$backup_name"
    
    echo -e "${YELLOW}Creating backup: $backup_name${NC}"
    
    mkdir -p "$backup_path"
    
    # Backup world and player data
    if [[ -d "$server_path/world" ]]; then
        cp -r "$server_path/world" "$backup_path/"
        echo -e "${GREEN}World backed up successfully!${NC}"
    fi
    
    if [[ -d "$server_path/world_nether" ]]; then
        cp -r "$server_path/world_nether" "$backup_path/"
    fi
    
    if [[ -d "$server_path/world_the_end" ]]; then
        cp -r "$server_path/world_the_end" "$backup_path/"
    fi
    
    # Manage backup retention (keep last 3 + initial)
    local backups=($(find "$BACKUPS_DIR" -maxdepth 1 -type d -name "${server_name}_*" | sort))
    local backup_count=${#backups[@]}
    
    # Keep initial backup (first one) and last 3
    if [[ $backup_count -gt 4 ]]; then
        local first_backup="${backups[0]}"
        # Remove middle backups, keep first and last 3
        for ((i=1; i<$((backup_count-3)); i++)); do
            if [[ "${backups[$i]}" != "$first_backup" ]]; then
                echo -e "${YELLOW}Removing old backup: $(basename ${backups[$i]})${NC}"
                rm -rf "${backups[$i]}"
            fi
        done
    fi
}

# Restore from backup
restore_backup() {
    show_title
    echo -e "${WHITE}=== Restore from Backup ===${NC}\n"
    
    if ! list_servers; then
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter server number to restore: " server_num
    
    local servers=($(find "$SERVERS_DIR" -maxdepth 1 -type d -not -path "$SERVERS_DIR" | sort))
    
    if [[ ! "$server_num" =~ ^[0-9]+$ ]] || [[ "$server_num" -lt 1 ]] || [[ "$server_num" -gt ${#servers[@]} ]]; then
        echo -e "${RED}Invalid server number!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local server_path="${servers[$((server_num-1))]}"
    local server_name=$(basename "$server_path")
    
    # List backups for this server
    local backups=($(find "$BACKUPS_DIR" -maxdepth 1 -type d -name "${server_name}_*" | sort))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo -e "${RED}No backups found for server '$server_name'!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "\n${WHITE}Available backups for '$server_name':${NC}"
    for i in "${!backups[@]}"; do
        local backup_name=$(basename "${backups[$i]}")
        echo -e "${CYAN}$((i+1)))${NC} $backup_name"
    done
    
    read -p "Enter backup number to restore: " backup_num
    
    if [[ ! "$backup_num" =~ ^[0-9]+$ ]] || [[ "$backup_num" -lt 1 ]] || [[ "$backup_num" -gt ${#backups[@]} ]]; then
        echo -e "${RED}Invalid backup number!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local backup_path="${backups[$((backup_num-1))]}"
    
    echo -e "${RED}WARNING: This will overwrite the current world data!${NC}"
    read -p "Are you sure? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Restore cancelled.${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check if server is running
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        local current_dir=$(tmux display-message -t "$TMUX_SESSION" -p "#{pane_current_path}")
        if [[ "$current_dir" == "$server_path" ]]; then
            echo -e "${YELLOW}Server is running, stopping it first...${NC}"
            stop_server_silent
            sleep 2
        fi
    fi
    
    echo -e "${YELLOW}Restoring backup...${NC}"
    
    # Remove current world data
    rm -rf "$server_path/world" "$server_path/world_nether" "$server_path/world_the_end"
    
    # Restore from backup
    if [[ -d "$backup_path/world" ]]; then
        cp -r "$backup_path/world" "$server_path/"
    fi
    if [[ -d "$backup_path/world_nether" ]]; then
        cp -r "$backup_path/world_nether" "$server_path/"
    fi
    if [[ -d "$backup_path/world_the_end" ]]; then
        cp -r "$backup_path/world_the_end" "$server_path/"
    fi
    
    echo -e "${GREEN}Backup restored successfully!${NC}"
    read -p "Press Enter to continue..."
}

# Attach to console
attach_console() {
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo -e "${RED}No server is currently running!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${WHITE}Attaching to server console...${NC}"
    echo -e "${YELLOW}Use Ctrl+B then D to detach from the session${NC}"
    sleep 2
    tmux attach -t "$TMUX_SESSION"
}

# View server status
server_status() {
    show_title
    echo -e "${WHITE}=== Server Status ===${NC}\n"
    
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        local current_dir=$(tmux display-message -t "$TMUX_SESSION" -p "#{pane_current_path}")
        local server_