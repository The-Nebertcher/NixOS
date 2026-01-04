#!/run/current-system/sw/bin/zsh

LOG_FILE="nixos-switch.log"

# Run nixos-rebuild and handle error detection
sudo nixos-rebuild switch &>"$LOG_FILE"
if [ $? -eq 0 ]; then
    # Put commands to run on success here
    mkdir -p /mnt/backup/git_repos/nixos/$(date +%y%m%d_%H%M%S) &>/dev/null
    cp -aRfv /etc/nixos/* /mnt/backup/git_repos/nixos/$(date +%y%m%d_%H%M%S)/ &>/dev/null
    cd /mnt/backup/git_repos/nixos/$(date +%y%m%d_%H%M%S)/ &>/dev/null
    git add * &>/dev/null
    git commit -m "New Rebuild pushed on $(date +%y%m%d_%H%M%S)"
    git push origin main &>/dev/null
else
  echo "Rebuild failed..."
  cat "$LOG_FILE" | grep --color error && false
fi




