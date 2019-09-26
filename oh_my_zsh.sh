#!/bin/bash
sudo apt update
sudo apt -y install zsh
sudo usermod -s /usr/bin/zsh $(whoami)
chsh -s $(which zsh)
sudo apt -y install powerline fonts-powerline zsh-syntax-highlighting
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
sudo git clone https://github.com/romkatv/powerlevel10k.git /usr/share/powerlevel10k
echo 'source /usr/share/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc