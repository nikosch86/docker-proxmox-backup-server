#!/bin/bash
set -e

# Function to properly shutdown services
shutdown() {
  echo "Shutting down services..."
  # Send TERM to all services managed by runit
  sv down /runit/proxmox-backup-api
  sv down /runit/proxmox-backup-proxy

  # Give services time to terminate gracefully
  sleep 2

  # Kill any remaining processes if needed
  echo "Shutdown complete"
  exit 0
}

# Setup signal trap
trap shutdown SIGTERM SIGINT

# Start runit in the background
runsvdir /runit &
RUNIT_PID=$!

# Wait for runit to exit or for signals
wait $RUNIT_PID

# If we get here without a signal, something went wrong
echo "Runsvdir exited unexpectedly"
exit 1