#!/bin/sh
# Builds the web copy from ../joshuatree, then deploys the landing to mirage.jaybulb.com.
set -e
cd "$(dirname "$0")"
./build.sh
npx wrangler deploy
