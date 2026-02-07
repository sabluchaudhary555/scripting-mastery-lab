# System Information Display Script

A simple Bash script that displays comprehensive system information including user details, operating system, shell version, and more.

## 📋 Project Description

This project is a beginner-friendly Bash script that demonstrates fundamental shell scripting concepts. It retrieves and displays various system information in a clean, formatted output.

## ✨ Features

- Display current user information
- Show hostname and system details
- Display operating system and version
- Show system architecture
- Display current shell and Bash version
- Show current date, time, and system uptime
- Display working directory and home directory

## 🎯 Learning Objectives

This project covers the following Bash scripting fundamentals:
- Using shebang (`#!/bin/bash`)
- Making scripts executable with `chmod`
- Running scripts using different methods
- Working with environment variables
- Using command substitution
- Basic output formatting with `echo`

## 📦 Prerequisites

- Linux, macOS, or Windows with WSL (Windows Subsystem for Linux)
- Bash shell (version 4.0 or higher recommended)
- Basic terminal knowledge

## 🚀 Installation

1. **Clone the repository:**
```bash
   git clone https://github.com/yourusername/system-info-script.git
```

2. **Navigate to the project directory:**
```bash
   cd system-info-script
```

3. **Make the script executable:**
```bash
   chmod +x system_info.sh
```

## 💻 Usage

There are multiple ways to run this script:

### Method 1: Direct execution (Recommended)
```bash
./system_info.sh
```

### Method 2: Using bash command
```bash
bash system_info.sh
```

### Method 3: Using source command
```bash
source system_info.sh
```

## 📸 Sample Output
```
==================================
   SYSTEM INFORMATION DISPLAY
==================================

👤 Current User: john
🖥️  Hostname: laptop-ubuntu
💻 Operating System: Linux
📋 OS Release: 5.15.0-56-generic
⚙️  Architecture: x86_64
🐚 Current Shell: /bin/bash
🔧 Bash Version: 5.1.16(1)-release
📅 Date & Time: Sat Feb 07 10:30:45 EST 2026
⏱️  System Uptime: up 2 hours, 15 minutes
📁 Current Directory: /home/john/projects
🏠 Home Directory: /home/john

==================================
   End of System Information
==================================
```

## 📂 Project Structure
```
system-info-script/
│
├── system_info.sh          # Main bash script
├── README.md              # Project documentation
└── LICENSE                # License file (optional)
```

## 🛠️ Technical Details

### Commands Used

- `whoami` - Display current user
- `hostname` - Display system hostname
- `uname` - Display system information
- `date` - Display current date and time
- `uptime` - Display system uptime
- `pwd` - Display current working directory

### Environment Variables

- `$SHELL` - Path to current shell
- `$BASH_VERSION` - Bash version information
- `$HOME` - User's home directory

## 🧪 Testing

To verify the script works correctly:

1. Run the script and check if all information is displayed
2. Compare output with manual commands:
```bash
   whoami
   hostname
   uname -a
   echo $BASH_VERSION
```



<br>
<br>

**Happy Learning! 🚀**

*Contributions and suggestions are welcome!*

---

**Maintained by: [Sablu Chaudhary](https://github.com/sabluchaudhary555)** 🔗 **Connect with me:** [LinkedIn](https://www.linkedin.com/in/sablu-chaudhary555/) | [GitHub](https://github.com/sabluchaudhary555) | [SSoft.in](https://ssoft.in/)]

---
**Made with ❤️ for the Open Source Community**


<br>


**Note:** This is a learning project created as part of Bash scripting fundamentals. Feel free to use it for educational purposes!