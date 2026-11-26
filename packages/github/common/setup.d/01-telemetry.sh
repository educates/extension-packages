#!/bin/sh

# Turns off gh's telemetry in the session, by setting GH_TELEMETRY=false in
# the session's environment, which every terminal inherits and the later
# setup scripts run with. Running it again sets it again.

set -e

echo "GH_TELEMETRY=false" >> "$WORKSHOP_ENV"
