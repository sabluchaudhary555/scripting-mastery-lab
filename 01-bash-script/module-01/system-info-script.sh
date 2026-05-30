#!/bin/bash

# System Information Display Script
# This script displays basic system information


# Display current user
echo "👤 Current User: $(whoami)"

# Display hostname
echo "🖥️  Hostname: $(hostname)"

# Display operating system
echo "💻 Operating System: $(uname -s)"

# Display OS version/release
echo "📋 OS Release: $(uname -r)"

# Display machine architecture
echo "⚙️  Architecture: $(uname -m)"

# Display shell being used
echo "🐚 Current Shell: $SHELL"

# Display bash version
echo "🔧 Bash Version: $BASH_VERSION"

# Display current date and time
echo "📅 Date & Time: $(date)"

# Display uptime
echo "⏱️  System Uptime: $(uptime -p 2>/dev/null || uptime)"

# Display current working directory
echo "📁 Current Directory: $(pwd)"

# Display home directory
echo "🏠 Home Directory: $HOME"

