# !/bin/bash
# This script sets up a transient timer to run a curl command every day at 7:00 AM.

# Check the calendar expression for the timer
systemd-analyze calendar "*-*-* 07:00:00"

# Create a transient timer that runs the curl command at the specified time
systemd-run --on-calendar="*-*-* 07:00:00" curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/xxxx

# List all timers to verify that the transient timer has been created
systemctl list-timers --all


# Calendar expressions format:
#   *-*-*                 →    any year, month, day
#   *-*-1                 →    1st of every month
#   Mon *-*-*             →    every Monday
#   Mon..Fri *-*-*        →    weekdays
#   *-*-* 07:00:00        →    every day at 07:00
#   *-*-1 07:00:00        →    1st of month at 07:00
#   Mon *-*-* 07:00:00    →    every Monday at 07:00