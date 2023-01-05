#!/bin/bash
# Copyright (c) 2023 The Brave Authors. All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at https://mozilla.org/MPL/2.0/. */

set -euo pipefail
IFS=$'\n\t'

task="${1-run-all}"

mkdir -p output

function die_usage() {
  echo "$0 usage:"
  echo "  defaults to 'csv-to-json' command"
  echo ""
  echo "  $0 run-all                     Run all the required end-to-end (For deployment)"
  echo "  $0 shell                       Start a bpython shell"
  exit 1
}

if [[ "$task" = "run-all" ]]; then
  if [[ ! -d "output/" ]]; then
    echo "Error: output/ dir not found!"
    echo "Are you in the from root directory?"
    exit 1
  fi

  set -x

  echo "Init feed sources"
  python -u src/csv_to_json.py feed.json

  echo "Generating sources.global.json"
  python -u src/csv_to_global_json.py

  echo "Starting main script..."
  mkdir -p output/feed/cache
  python -u src/feed_processor_multi.py

  echo "Shutting down squid..."
  kill $(pidof squid)

elif [[ "$task" = "shell" ]]; then
  set -x
  bpython

elif [[ "$task" = "help" || "$task" = "-h" || "$task" = "--help" ]]; then
  die_usage

else
  echo "unknown cmd: $task"
  die_usage
fi
