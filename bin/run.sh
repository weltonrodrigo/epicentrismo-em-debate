#!/bin/bash
#
#
set -euo pipefail

git add *.json && git commit -m "$(date)" && git pull
