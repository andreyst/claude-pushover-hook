#!/bin/bash

# Claude Code Pushover Notification Hook
# This script sends notifications to Pushover when Claude Code events occur

# Configuration
PUSHOVER_TOKEN="${PUSHOVER_TOKEN}"
PUSHOVER_USER="${PUSHOVER_USER}"
PUSHOVER_API_URL="https://api.pushover.net/1/messages.json"

# Check if required environment variables are set
if [[ -z "$PUSHOVER_TOKEN" || -z "$PUSHOVER_USER" ]]; then
    echo "Error: PUSHOVER_TOKEN and PUSHOVER_USER environment variables must be set" >&2
    exit 1
fi

# Read JSON input from stdin
INPUT_JSON=$(cat)

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for JSON parsing" >&2
    exit 1
fi

# Parse JSON to extract hook event name and relevant data
HOOK_EVENT=$(echo "$INPUT_JSON" | jq -r '.hook_event_name // "unknown"')
TOOL_NAME=$(echo "$INPUT_JSON" | jq -r '.tool_name // empty')
USER_PROMPT=$(echo "$INPUT_JSON" | jq -r '.prompt // empty')
SESSION_ID=$(echo "$INPUT_JSON" | jq -r '.session_id // empty')
NOTIFICATION_MESSAGE=$(echo "$INPUT_JSON" | jq -r '.message // empty')

# Create notification message based on event type
case "$HOOK_EVENT" in
    "PreToolUse")
        if [[ -n "$TOOL_NAME" ]]; then
            MESSAGE="About to execute tool '$TOOL_NAME'"
        else
            MESSAGE="About to execute tool"
        fi
        ;;
    "UserPromptSubmit")
        if [[ -n "$USER_PROMPT" ]]; then
            PROMPT_PREVIEW=$(echo "$USER_PROMPT" | head -c 100)
            MESSAGE="User submitted prompt: $PROMPT_PREVIEW..."
        else
            MESSAGE="User submitted a prompt"
        fi
        ;;
    "Stop"|"SubagentStop")
        MESSAGE="Agent has completed"
        ;;
    "Notification")
        if [[ -n "$NOTIFICATION_MESSAGE" ]]; then
            MESSAGE="$NOTIFICATION_MESSAGE"
        else
            MESSAGE="Notification received"
        fi
        ;;
    *)
        MESSAGE="Event '$HOOK_EVENT' occurred"
        ;;
esac

# Send notification to Pushover
curl -s \
    --form-string "token=$PUSHOVER_TOKEN" \
    --form-string "user=$PUSHOVER_USER" \
    --form-string "message=$MESSAGE" \
    --form-string "title=Claude Code - $HOOK_EVENT" \
    "$PUSHOVER_API_URL" > /dev/null

# Check if curl command was successful
if [[ $? -eq 0 ]]; then
    echo "Notification sent successfully"
else
    echo "Failed to send notification" >&2
    exit 1
fi
