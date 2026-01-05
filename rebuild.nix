with import <nixpkgs> {};
writeShellScriptBin "rebuild" ''
LOG_FILE="/tmp/nixos-switch.log"

# Function to display a loading bar
show_progress() {
    local progress=$1
    local width=40
    local filled=$(( progress * width / 100 ))
    local empty=$(( width - filled ))
    printf "\r[" >/dev/tty
    printf "%''${filled}s" "" | tr ' ' '#' >/dev/tty
    printf "%''${empty}s" "" | tr ' ' '-' >/dev/tty
    printf "] %d%%" "$progress" >/dev/tty
}

# Run nixos-rebuild and handle error detection
echo "Starting NixOS rebuild..."
sudo nixos-rebuild switch &>"$LOG_FILE"
if [ $? -eq 0 ]; then
  rm -f $LOG_FILE
  echo "Rebuild successful. Starting backup and git push..."
  show_progress 0
  mkdir -p /mnt/backup/git_repos/nixos/ &>/dev/null
  show_progress 20

  cp -aRfv /etc/nixos/* /mnt/backup/git_repos/nixos/ &>/dev/null
  show_progress 40

  cd /mnt/backup/git_repos/nixos/ &>/dev/null
  show_progress 60

  git add * &>/dev/null
  show_progress 70

  git commit -m "New Rebuild pushed on $(date +%Y%m%d)" &>/dev/null
  show_progress 90

  git push origin main &>/dev/null
  show_progress 100
  echo -e "\nDone!"
else

  cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢤⡰⢆⠦⡤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⣀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠶⣙⡎⢶⡙⣮⢓⡳⡜⢮⡹⢖⡢⠀⢀⡠⣔⢮⡙⢧⠳⣍⠾⣩⢗⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠶⣩⢞⡱⢞⣣⡝⠦⠻⠴⠫⠷⠙⢮⣝⣃⢩⠳⡜⢶⣙⢮⣓⢮⡓⢧⢞⡹⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡞⡹⢆⣏⠞⢉⣠⠴⣚⢧⣋⠗⣎⡳⢦⡌⣁⢈⣋⣉⡥⢬⠥⡭⢬⠭⡭⢬⠥⣉⣂⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⢗⡺⣍⠯⡤⢼⡩⢖⣫⠵⣪⢼⡹⠲⠙⣒⡙⡚⣂⠐⠧⢞⡭⢞⡱⡏⠞⢱⢋⡚⣑⢊⡓⠢⠄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⡝⢮⡱⢎⣳⡙⢶⣩⠳⣎⠳⡉⠄⣂⣉⣍⡱⣭⠳⣍⡻⣜⢂⠘⠧⠒⢒⣉⣩⠬⡥⢭⡩⢬⣉⠚⠢⠄⠀⠀
⠀⠀⠀⠀⠀⠀⢀⡔⢰⡹⣜⢣⡝⣭⠲⣭⠳⠎⠥⠔⣨⢔⣫⢖⡳⣬⠳⠣⠛⠼⣱⡋⠾⠡⢰⣋⠯⠖⠣⣛⡉⠃⠋⠓⢉⣛⣙⠖⢦⡀
⠀⠀⠀⠀⠀⡰⣏⠂⢧⢳⢭⣚⡜⢦⡛⡄⠒⠲⠎⠽⠚⠞⣂⣋⠁⢀⡀⠀⠈⠙⢿⣿⣿⡿⢠⣴⣶⣿⣿⠟⠁⡄⠀⣀⠀⠘⣿⣿⣷⡄
⠀⠀⠀⠀⣜⡱⣭⢲⣋⢞⢦⠳⣜⡣⣝⢺⡙⡇⠎⣙⡻⢿⣿⠋⠀⢈⠁⢾⣷⠀⠈⣿⠟⠁⠻⣿⣿⣿⣿⠀⠀⠄⠘⠛⠁⠀⠸⠛⠋⠀
⠀⠀⠀⢰⢎⡵⢎⡳⢬⣋⢮⢳⡌⢷⡘⢧⡹⣱⠳⣌⣉⠓⠢⠤⠄⠌⠀⠤⠄⠤⠐⠀⣡⠞⣝⣖⡲⢴⡤⢦⠤⡴⢤⣒⢦⠻⠉⠀⠀⠀
⠀⠀⢠⢏⡞⣜⡣⢏⡳⢬⢣⣓⠞⣥⢛⠦⣝⢲⡹⡜⡬⢏⣳⢣⣛⢎⡟⢮⠝⢊⢥⠺⣥⢛⠶⣨⢙⠒⣊⢃⣛⡘⣃⠉⠀⠀⠀⠀⠀⠀
⠀⢀⡏⡾⡸⢶⣉⢷⠹⡎⢷⣈⠿⣰⢏⡹⣈⢇⢷⡉⢷⣉⠶⣇⠾⠎⣉⡰⣎⠹⣎⡹⣆⠏⣷⢇⡏⣶⢸⡉⣶⢹⡸⣆⠀⠀⠀⠀⠀⠀
⢠⠞⣼⢱⣙⠮⡜⣎⡳⢭⡓⣎⡳⡱⢎⡵⣩⠞⣦⢹⡲⣍⠞⣬⢏⡝⢦⢳⡜⡹⢆⠷⣸⡙⢦⢫⡜⢦⡳⣙⢦⢣⠗⣎⢶⡀⠀⠀⠀⠀
⢨⣛⢴⢫⣜⢣⣝⢲⣙⢦⡝⢦⢳⡙⣎⠶⣣⢻⠴⣣⠷⡼⣹⢆⡟⡼⣩⠶⣹⣙⢮⠳⣥⢛⣬⠳⣜⢣⡳⣍⢎⢧⣛⡜⣎⠷⡀⠀⠀⠀
⠸⡜⣎⢳⢬⠳⣬⢓⢮⢲⡙⣎⠧⣝⡜⡣⠋⡁⠤⣀⠆⡰⠠⢄⠨⡁⠓⠫⠵⠺⣼⣙⢦⣛⢦⣛⣬⣓⡳⣜⢮⢳⡜⠮⠵⠋⣁⠀⠀⠀
⠈⢳⣜⢣⢞⡹⢆⡏⣎⢧⡹⢬⢳⠞⡜⠁⡰⢡⠃⢄⠡⣁⠉⠤⣁⠑⠉⠦⡐⢢⠄⣄⠢⠄⠤⡀⢄⡠⠄⣄⠢⢄⡐⢢⠰⠁⠆⠀⠀⠀
⠀⠘⣬⡓⣎⡳⣍⠞⡜⢦⢫⣝⡈⢯⡱⣆⣀⣁⢊⣀⣃⣀⡙⠒⠠⠍⡜⡐⠰⢠⠄⡄⡉⢌⡁⢌⠠⣀⢉⠠⡁⢌⠠⢆⠂⠀⠀⠀⠀⠀
⠀⠀⠀⠻⣔⢫⡜⢯⣜⣣⢏⠶⣱⢤⡙⢲⡍⣞⢣⠞⡴⣣⠝⣭⢳⠲⡔⢦⠥⡤⣌⢤⣉⣠⣈⣂⣃⣈⣈⣑⣈⣈⠁⠈⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⢚⠃⠾⠴⢫⣝⡚⡦⢏⡳⡼⣡⢏⡞⡵⢣⣛⢦⣋⠷⣙⠮⣝⠲⣭⢲⡱⢆⡳⣜⣲⡱⠏⠖⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠂⠠⠀⠉⠘⠒⠦⢤⡍⣍⣉⢓⡑⠋⠮⠝⡼⢣⡝⣦⣹⢚⣭⣓⢮⣛⡴⢣⠯⠝⠣⠙⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡁⠄⠂⠐⢀⠠⠀⠀⠀⠁⠉⠊⠙⠋⠷⢺⡴⣓⡖⢦⣒⢦⡲⣔⠦⣖⠲⠒⠊⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠄⢀⠂⠁⠠⠀⠄⠁⠂⠐⡀⠄⠂⢀⠀⠀⠀⠀⠀⠁⠉⠀⠁⠀⠀⠀⢀⠀⠄⠐⠀⡁⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠠⠈⢀⠠⠈⢀⠐⠀⠌⠀⡁⠀⠄⠂⠠⠈⢀⠡⠐⠈⠀⠄⠂⠠⠁⢈⠠⠀⠂⠠⠈⠀⠄⠐⡀⠁⡀⠀⠀⠀⠀⠀
EOF
  echo -e "\e[31m"
  echo "Rebuild failed...NOT POGGERS!"
  echo -e "\e[0m"
  cat "$LOG_FILE" | grep --color error && false
fi
''
