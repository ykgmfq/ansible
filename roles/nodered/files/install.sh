#!/usr/bin/bash
set -eu
npm install passport-openidconnect \
node-red-contrib-{sun-position@2.1.x,timed-counter,home-assistant-websocket@0.62.x,spline-curve}
rm -- "$0"
