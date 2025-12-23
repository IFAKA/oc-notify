---
name: Bug Report
about: Report a bug or issue with oc-notify
title: '[BUG] '
labels: bug
assignees: ''
---

## Describe the Bug

A clear description of what the bug is.

## To Reproduce

Steps to reproduce the behavior:
1. Start OpenCode with '...'
2. Trigger '...'
3. See error

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

**Platform:** (e.g., macOS 13.0, Arch Linux, Windows 11, WSL Ubuntu)

**OpenCode Version:**
```bash
opencode --version
```

**Terminal:** (e.g., Ghostty, Terminal.app, Alacritty, etc.)

**Audio Method:** (e.g., afplay, speaker-test, bell - check OpenCode startup logs)

## Debug Logs

Enable debug mode and paste logs:

```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

```
Paste OpenCode startup logs here
```

## Configuration

If using custom config, paste relevant parts:

```json
{
  "audio_notifications": {
    // Your config here
  }
}
```

## Additional Context

Any other information that might be helpful.
