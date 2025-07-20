# claude-pushover-hook

A Claude Code hook that sends notifications to Pushover API when Claude Code events occur.

## Prerequisites

1. A Pushover account (sign up at https://pushover.net/)
2. Create a Pushover application to get your API token
3. Note your user key from your Pushover dashboard

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x notify.sh
   ```

3. Set up environment variables with your Pushover credentials:
   ```bash
   export PUSHOVER_TOKEN="your_app_token_here"
   export PUSHOVER_USER="your_user_key_here"
   ```

4. Configure Claude Code to use this hook by adding it to your Claude Code settings. The hook can be triggered on various events like tool calls, errors, or task completions.

## Usage

The script receives JSON input from Claude Code via stdin containing hook event data. It automatically processes events like:
- `PreToolUse`: When Claude Code is about to execute a tool
- `UserPromptSubmit`: When a user submits a prompt
- `Stop`/`SubagentStop`: When a session ends

The hook is automatically triggered by Claude Code - no manual execution needed.

## Configuration

Set these environment variables:
- `PUSHOVER_TOKEN`: Your Pushover application API token
- `PUSHOVER_USER`: Your Pushover user key

## Supported Events

The hook handles different Claude Code event types:
- `PreToolUse`: Notifications when Claude Code is about to execute a tool
- `UserPromptSubmit`: Notifications when users submit prompts
- `Stop`/`SubagentStop`: Notifications when sessions end
- Other events: Any other hook event with generic messages

## Troubleshooting

- Ensure `curl` and `jq` are installed on your system
- Verify your Pushover token and user key are correct
- Check that environment variables are properly set
- The script automatically processes JSON from Claude Code hooks