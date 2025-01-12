#!/bin/bash

set -xe

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# function：install Homebrew, have some bugs 
install_brew() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # check now shell is zsh
        if [[ "$SHELL" == */zsh ]]; then
            if ! command_exists brew; then
                echo "Homebrew not installed, installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if command_exists brew; then
                    echo "Homebrew install success"
                    # add Homebrew to path 
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
                    eval "$(/opt/homebrew/bix/brew shellenv)"
                else
                    echo "Homebrew install failed"
                    exit 1
                fi
            else
                echo "Homebrew already installed"
                # update Homebrew
                echo "update Homebrew..."
                brew update
                if [ $? -eq 0 ]; then
                    echo "Homebrew install success"
                else
                    echo "Homebrew install failed"
                    exit 1
                fi
            fi
        else
            echo "now shell is not zsh，jump Homebrew install" 
        fi
    else
        echo "not macOS, not install Homebrew"
    fi
}


install_zsh() {
    if [[ "$OSTYPE" == "darvin"* ]]; then
        # macos
        if ! command_exists brew ; then
            echo "brew not installed, installing..."
            exit 1
        fi
        brew install zsh
    elif [ -f /etc/os-release ]; then
        # find os type
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y zsh
                ;;
            fedora)
                sudo dnf install -y zsh
                ;;
            arch)
                sudo pacman -Syu --noconfirm zsh
                ;;
            centos|rhel)
                sudo yum install -y zsh
                ;;
            openSUSE)
                sudo zypper install -y zsh
                ;;
            *)
                echo "invalid Linux: $ID"
                exit 1
                ;;
        esac
    else 
       echo "invalid OS: $OSTYPE"
        exit 1
    fi
}


# check zsh
if command_exists zsh; then
    echo "zsh already installed"
else
    install_zsh
    if command_exists zsh; then
        echo "zsh installed success"
    else
        echo "zsh install failed"
        exit 1
    fi
fi

# change shell
# this code has some bugs, but some ides such as vscode have function
# to change shell
# you can use it to change shell
# if [ "$SHELL" != "$(which zsh)" ]; then
#     echo "change shell to zsh"
#     chsh -s "$(which zsh)"
#     echo "change success"
# else
#     echo "zsh is already your shell"
# fi

# install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "install oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    if [ $? -eq 0 ]; then
        echo "oh-my-zsh install success"
    else
        echo "oh-my-zsh install failed"
        exit 1
    fi
else
    echo "oh-my-zsh already installed"
fi


install_ohmyzsh_plugins() {
    echo "installing oh-my-zsh plugins"

    plugins=(git colorize github jira vagrant virtualenv pip python brew zsh-syntax-highlighting zsh-autosuggestions)
    plugins_str="${plugins[*]}"

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME}/.oh-my-zsh/custom"

    # update .zsh file's plugins list
    sed -i.bak "s#^plugins=(.*)#plugins=($plugins_str)#" "$HOME/.zshrc"

    #install zsh-syntax-highlighting
    if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
        echo "install zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting plugin already installed"
    fi

    # install zsh-autosuggestions 
    if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
        echo "install zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions plugin already installed"
    fi

    echo "Oh My Zsh plugins install success"
}

install_ohmyzsh_plugins

