#!/bin/bash

# Check if the wf-recorder process is running
if pgrep -x "wf-recorder" > /dev/null; then
    echo '{"text": "🔴 STOP", "tooltip": "A recording is in progress.\nClick to stop.", "class": "recording"}'
else
    # If wf-recorder is not running, output empty text to hide the module
    echo '{"text": ""}'
fi
