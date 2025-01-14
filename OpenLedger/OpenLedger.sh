#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

CHECKMARK="✅"
ERROR="❌"
PROGRESS="⏳"
INSTALL="🛠️"
STOP="⏹️"
RESTART="🔄"
LOGS="📄"
EXIT="🚪"
INFO="ℹ️"

# ----------------------------
# Check if packages are already installed
# ----------------------------

check_package_installed() {
    dpkg -l | grep -i $1 &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${CHECKMARK} $1 is already installed.${RESET}"
    else
        echo -e "${ERROR} $1 is not installed. Installing...${RESET}"
        return 1
    fi
    return 0
}

# ----------------------------
# Install required packages if they are not installed
# ----------------------------

install_required_packages() {
    sudo apt update && sudo apt upgrade -y
    packages=("unzip" "libasound2" "libasound2t64" "libgtk-3-0" "libnotify4" "libnss3" "libxss1" "libxtst6" "xdg-utils" "libatspi2.0-0" "libsecret-1-0" "libgbm1" "desktop-file-utils")
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -i $package &>/dev/null; then
            echo -e "${ERROR} $package is not installed. Installing...${RESET}"
            sudo apt-get install -y $package
        else
            echo -e "${CHECKMARK} $package is already installed.${RESET}"
        fi
    done
}

# ----------------------------
# Install Docker and Docker Compose
# ----------------------------
install_docker() {
    echo -e "${INSTALL} Installing Docker and Docker Compose...${RESET}"
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${CHECKMARK} Docker and Docker Compose installed successfully.${RESET}"
}

# ----------------------------
# Stop OpenLedger Containers
# ----------------------------
stop_openledger() {
    echo -e "${STOP} Stopping OpenLedger containers...${RESET}"
    docker stop opl_scraper opl_worker
    echo -e "${CHECKMARK} OpenLedger containers stopped.${RESET}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Install OpenLedger
# ----------------------------
install_openledger() {
    echo -e "${INSTALL} Installing OpenLedger...${RESET}"
    install_required_packages

    # Download OpenLedger
    wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip

    # Install OpenLedger
    unzip openledger-node-1.0.0-linux.zip
    sudo dpkg -i openledger-node-1.0.0.deb
    
    install_docker

    echo -e "${CHECKMARK} OpenLedger installed successfully.${RESET}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Start OpenLedger Node
# ----------------------------
start_openledger() {
    echo -e "${PROGRESS} Starting OpenLedger Node...${RESET}"
    openledger-node --no-sandbox
    echo -e "${CHECKMARK} OpenLedger Node started.${RESET}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Display ASCII Art and Welcome Message
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}    __  ___   ____  ____  ____    _   __${RESET}"
    echo -e "    ${GREEN}   /  |/  /  / __ \/ __ \/ __ \  / | / /${RESET}"
    echo -e "    ${BLUE}  / /|_/ /  / /_/ / /_/ / /_/ / /  |/ / ${RESET}"
    echo -e "    ${YELLOW} / /  / /  / _, _/ _, _/ _, _/ / /|  /  ${RESET}"
    echo -e "    ${MAGENTA}/_/  /_/  /_/ |_/_/ |_/_/ |_/ /_/ |_/   ${RESET}"
    echo -e "    ${MAGENTA}🚀 Follow us on Telegram: https://t.me/Maranscrypto${RESET}"
    echo -e "    ${MAGENTA}📢 Follow us on Twitter: https://x.com/Maranscrypto${RESET}"
    echo -e ""
    echo -e "    ${GREEN}Welcome to the OpenLedger Node Installation Wizard!${RESET}"
    echo -e ""
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    display_ascii
    echo -e "    ${YELLOW}Choose an option:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install OpenLedger"
    echo -e "    ${CYAN}2.${RESET} ${STOP} Stop OpenLedger Containers"
    echo -e "    ${CYAN}3.${RESET} ${INSTALL} Start OpenLedger Node"
    echo -e "    ${CYAN}4.${RESET} ${EXIT} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-4]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_openledger
            ;;
        2)
            stop_openledger
            ;;
        3)
            start_openledger
            ;;
        4)
            echo -e "${EXIT} Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
