#!/bin/bash
set -e

apt install git lynx curl htop net-tools xz-utils mlocate rsync

wget https://github.com/cheat/cheat/releases/download/4.2.0/cheat-linux-amd64.gz
gunzip cheat-linux-amd64.gz
chmod a+x cheat-linux-amd64
mv cheat-linux-amd64 /bin/cheat
mkdir -p ~/.config/cheat && cheat --init > ~/.config/cheat/conf.yml
