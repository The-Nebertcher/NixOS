#!/run/current-system/sw/bin/zsh

# Define the log file
LOG_FILE="nixos-switch.log"

# Run nixos-rebuild and handle error detection
if sudo nixos-rebuild switch &>"$LOG_FILE" || (cat "$LOG_FILE" | grep --color error && false); then
    echo "Rebuild successful. Cloning to local repo and pushing to Git..."
    # Put commands to run on success here
    mkdir -p /mnt/backup/git_repos/nixos/	$(date +%Y%m%d%H%M%S)
    cp -aRfv /etc/nixos/* /mnt/backup/git_repos/nixos/	$(date +%Y%m%d%H%M%S)/
    cd /mnt/backup/git_repos/nixos/	$(date +%Y%m%d%H%M%S)/
    git add *
    git commit -m "New Rebuild pushed on 	$(date +%Y%m%d%H%M%S)"
    git push origin main

    rm -f $LOG_FILE
else
    echo "Rebuild failed. Running error handling commands..."
    # Print the error messages from the log
    cat "$LOG_FILE" | grep --color error
    rm -f $LOG_FILE
fi




