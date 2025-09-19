# MasterCraft - Minecraft Server Management System

🎮 A comprehensive bash-based Minecraft server management system with tmux integration, automatic backups, and multi-server type support.

## ✨ Features

- **Multi-Server Support**: Create and manage Vanilla, Paper, Spigot, and Fabric servers
- **World-Focused Management**: Designed around world management rather than server instances
- **Automatic Backups**: Creates backups on server stop with smart retention (keeps last 3 + initial)
- **Tmux Integration**: Runs servers in detachable tmux sessions
- **Pre-configured Settings**: Automatically sets up EULA, whitelist, ops, and server properties
- **Seed Support**: Custom world seeds with easy management
- **Datapack Support**: Automatic datapack installation to new worlds
- **Menu-Driven Interface**: Beautiful ASCII interface with color-coded options
- **Admin Management**: Pre-configured admin users with full operator permissions

## 📋 Prerequisites

### Required Dependencies

Before running MasterCraft, you need to install the following dependencies:

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install tmux java-runtime-headless wget jq nano
```

#### CentOS/RHEL 7/8
```bash
sudo yum install tmux java-11-openjdk-headless wget jq nano
```

#### Fedora
```bash
sudo dnf install tmux java-latest-openjdk-headless wget jq nano
```

#### Arch Linux
```bash
sudo pacman -S tmux jre-openjdk wget jq nano
```

### System Requirements

- **Operating System**: Linux (tested on Ubuntu, Debian, CentOS, Fedora, Arch)
- **RAM**: At least 8GB (script allocates 6GB to Minecraft servers)
- **Disk Space**: Minimum 10GB free space for servers and backups
- **Java**: OpenJDK 11 or higher (newer Minecraft versions require Java 17+)
- **Internet Connection**: Required for downloading server JARs

## 🚀 Installation

1. **Download the script**:
   ```bash
   wget https://your-domain.com/mastercraft.sh
   # OR copy the script content to a new file
   nano mastercraft.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x mastercraft.sh
   ```

3. **Run the script**:
   ```bash
   ./mastercraft.sh
   ```

## 📂 Directory Structure

MasterCraft creates the following directory structure in your home directory:

```
~/minecraft/
├── servers/           # Your server instances (worlds)
│   ├── MyWorld1/      # Individual server directory
│   ├── MyWorld2/      # Another server directory
│   └── ...
├── backups/           # Automatic backups
│   ├── MyWorld1_20241218_143022/
│   ├── MyWorld1_RESET_20241218_150000/
│   └── ...
├── datapacks/         # Place your datapacks here
│   ├── your_datapack.zip
│   └── README.txt
└── downloads/         # Cached server JARs and installers
    ├── fabric-installer.jar
    └── ...
```

## 🎮 Usage

### First Time Setup

1. **Install Dependencies** (see Prerequisites section above)
2. **Run the script**: `./mastercraft.sh`
3. **Create your first server** (Option 1)
4. **Add datapacks** to `~/minecraft/datapacks/` if desired
5. **Start your server** (Option 2)

### Menu Options

When you run the script, you'll see a menu with these options:

1. **Create New Server** - Create a new Minecraft server/world
2. **Start Server** - Start an existing server
3. **Stop Server (with backup)** - Safely stop server and create backup
4. **Restore from Backup** - Restore world from a previous backup
5. **Attach to Server Console** - Connect to the running server console
6. **View Server Status** - See current status and server information
7. **Manage Server Settings** - Change seeds, edit properties, reset worlds
8. **Delete Server** - Permanently remove a server (with final backup)
9. **Exit** - Close the application

### Server Types

- **Vanilla**: Official Minecraft server from Mojang
- **Paper**: High-performance Bukkit/Spigot alternative with optimizations
- **Spigot**: Bukkit-based server (requires manual compilation)
- **Fabric**: Lightweight modding platform

### Initial Server Configuration

By default, new servers are created with:
- **Whitelist**: Disabled (anyone can join)
- **Ops**: Empty (no admins by default)
- **Gamemode**: Survival
- **Difficulty**: Easy
- **PvP**: Enabled
- **Max Players**: 20

### Adding Players and Admins

**To add admins (ops)**:
1. Start your server
2. Attach to console (Menu Option 5)
3. Use command: `/op <playername>`
4. Or edit `~/minecraft/servers/[world]/ops.json` directly

**To enable whitelist and add players**:
1. Attach to server console
2. Use commands:
   - `/whitelist on` - Enable whitelist
   - `/whitelist add <playername>` - Add players
   - `/whitelist list` - View current whitelist
3. Or edit `~/minecraft/servers/[world]/whitelist.json` directly

## 🔧 Configuration

### Memory Allocation
By default, servers are allocated 6GB of RAM. To change this, edit the `MEMORY` variable at the top of the script:
```bash
MEMORY="4G"  # Change to desired amount
```

### Custom Datapacks
1. Place your datapacks (`.zip` files) in `~/minecraft/datapacks/`
2. They will be automatically copied to new worlds when servers start

### Server Properties
- Edit via Menu Option 7 → "Edit Server Properties"
- Or manually edit `~/minecraft/servers/[world-name]/server.properties`

## 🛠️ Troubleshooting

### Common Issues

**Script won't run / Permission denied**:
```bash
chmod +x mastercraft.sh
```

**Missing dependencies error**:
- Follow the dependency installation instructions for your OS above
- The script will tell you exactly which packages are missing

**Server fails to start**:
- Check Java version: `java -version` (needs Java 11+)
- Ensure server.jar downloaded properly
- Check tmux session: `tmux attach -t minecraft-server`

**Download fails**:
- Check internet connection
- Try creating server again (downloads can sometimes fail)
- For Spigot, manual compilation is required

**Can't attach to console**:
- Server might not be running
- Check server status (Menu Option 6)
- Try: `tmux list-sessions` to see active sessions

### Tmux Commands

Useful tmux commands when working with the server console:

- **Attach to server**: `tmux attach -t minecraft-server`
- **Detach from session**: `Ctrl+B` then `D`
- **List sessions**: `tmux list-sessions`
- **Kill session**: `tmux kill-session -t minecraft-server`

## 🔄 Backup System

### Automatic Backups
- Created every time you stop a server
- Includes world data and player information
- Keeps last 3 backups + initial backup as reset point

### Manual Backup Location
Backups are stored in: `~/minecraft/backups/`

Format: `[ServerName]_[Date]_[Time]/`

### Backup Contents
- `world/` - Overworld
- `world_nether/` - Nether dimension  
- `world_the_end/` - End dimension

## ⚠️ Important Notes

1. **Only one server runs at a time** - Starting a new server automatically stops the current one
2. **Backups are automatic** - Created every time you stop a server properly
3. **Datapacks** are copied to new worlds only, existing worlds need manual datapack installation
4. **Spigot servers** require manual compilation via BuildTools
5. **Server stopping** - Always use the script's stop function for proper backups

## 🆘 Support

### Log Files
Server logs are located in each server directory:
- `~/minecraft/servers/[world-name]/logs/latest.log`

### Getting Help
If you encounter issues:

1. Check the troubleshooting section above
2. Verify all dependencies are installed
3. Check server logs for specific error messages
4. Ensure you have sufficient disk space and RAM

### File Locations
- **Script**: Where you placed `mastercraft.sh`
- **Servers**: `~/minecraft/servers/`
- **Backups**: `~/minecraft/backups/`
- **Datapacks**: `~/minecraft/datapacks/`
- **Configuration**: Each server has its own `server.properties`

## 📝 Version History

- **v1.1**: Added seed support, admin management, server settings menu, delete function
- **v1.0**: Initial release with basic server management and backup system

---

**MasterCraft** - Created for world-focused Minecraft server management 🎮
