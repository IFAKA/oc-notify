# Configuration

Complete configuration reference for oc-notify.

## Overview

oc-notify works great with **zero configuration**. All settings are optional.

Configuration is stored in: `~/.config/opencode/opencode.json`

---

## Complete Configuration Schema

```json
{
  "audio_notifications": {
    "enabled": true,
    "debug": false,
    
    "permission": {
      "enabled": true,
      "method": "auto",
      "cooldown": 2,
      "tone": {
        "freq": 1000,
        "duration": 150
      },
      "bellPattern": "single"
    },
    
    "completion": {
      "enabled": true,
      "method": "auto",
      "cooldown": 5,
      "tone": {
        "freq": 600,
        "duration": 250
      },
      "bellPattern": "double"
    }
  }
}
```

---

## Options Reference

### `enabled`
**Type:** `boolean`  
**Default:** `true`

Master switch to enable/disable all audio notifications.

```json
{
  "audio_notifications": {
    "enabled": false
  }
}
```

---

### `debug`
**Type:** `boolean`  
**Default:** `false`

Enable detailed logging to see what the plugin is doing.

```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

**Example output:**
```
🔊 Audio Notify Plugin v1.0.0
📱 Platform: darwin
✅ Available audio methods: afplay, bell
🎵 Primary method: afplay
⚙️  Config: { "enabled": true, ... }
🔊 permission sound played
```

---

### `permission` / `completion`

Settings for each notification type.

#### `enabled`
**Type:** `boolean`  
**Default:** `true`

Enable/disable this specific notification type.

```json
{
  "audio_notifications": {
    "permission": { "enabled": true },
    "completion": { "enabled": false }
  }
}
```

---

#### `method`
**Type:** `string`  
**Default:** `"auto"`

Force a specific audio method instead of auto-detection.

**Options:**
- `"auto"` - Auto-detect best method (recommended)
- `"bell"` - Terminal bell only
- `"afplay"` - macOS system sounds
- `"speaker-test"` - Linux ALSA tones
- `"beep"` - Linux PC speaker
- `"paplay"` - Linux PulseAudio
- `"powershell-beep"` - Windows PowerShell

```json
{
  "audio_notifications": {
    "permission": { "method": "bell" },
    "completion": { "method": "speaker-test" }
  }
}
```

---

#### `cooldown`
**Type:** `number` (seconds)  
**Default:** `2` (permission), `5` (completion)

Minimum time between sounds of this type.

```json
{
  "audio_notifications": {
    "permission": { "cooldown": 5 },
    "completion": { "cooldown": 10 }
  }
}
```

**Use case:** Prevent sound spam during rapid interactions.

---

#### `tone`
**Type:** `object`

Settings for tone-based methods (speaker-test, beep, powershell-beep).

**Properties:**
- `freq` - Frequency in Hz (higher = higher pitch)
- `duration` - Duration in milliseconds

```json
{
  "audio_notifications": {
    "permission": {
      "tone": {
        "freq": 1200,
        "duration": 100
      }
    }
  }
}
```

**Frequency guide:**
- 400-600 Hz: Low, calm
- 600-800 Hz: Medium
- 800-1200 Hz: High, attention-grabbing
- 1200+: Very high, urgent

---

#### `bellPattern`
**Type:** `string`  
**Default:** `"single"` (permission), `"double"` (completion)

Pattern for terminal bell method.

**Options:**
- `"single"` - One beep
- `"double"` - Two beeps with delay

```json
{
  "audio_notifications": {
    "permission": { "bellPattern": "single" },
    "completion": { "bellPattern": "double" }
  }
}
```

---

## Common Configurations

### Minimal (Terminal bell only)

```json
{
  "audio_notifications": {
    "permission": { "method": "bell" },
    "completion": { "method": "bell" }
  }
}
```

---

### Quiet (Permission only, no completion)

```json
{
  "audio_notifications": {
    "completion": { "enabled": false }
  }
}
```

---

### Loud (Shorter cooldowns, higher frequency)

```json
{
  "audio_notifications": {
    "permission": {
      "cooldown": 1,
      "tone": { "freq": 1500, "duration": 200 }
    },
    "completion": {
      "cooldown": 2,
      "tone": { "freq": 800, "duration": 300 }
    }
  }
}
```

---

### Subtle (Longer cooldowns, lower frequency)

```json
{
  "audio_notifications": {
    "permission": {
      "cooldown": 10,
      "tone": { "freq": 600, "duration": 100 }
    },
    "completion": {
      "cooldown": 20,
      "tone": { "freq": 400, "duration": 150 }
    }
  }
}
```

---

### Debug Mode (See everything)

```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

---

## Platform-Specific Tips

### macOS
- `afplay` method gives you beautiful system sounds
- Default sounds are perfect, no need to configure

### Linux Desktop
- `paplay` uses system sounds (varies by distro)
- `speaker-test` is more consistent across distros

### Linux TTY
- Install `alsa-utils` for `speaker-test`
- Tone customization is most useful here
- Terminal bell is the most reliable fallback

### Windows
- PowerShell beep is your best option
- Tone customization works well

---

## Troubleshooting Config

### Config not loading?

**Check file location:**
```bash
cat ~/.config/opencode/opencode.json
```

**Check JSON syntax:**
```bash
cat ~/.config/opencode/opencode.json | jq .
```

If `jq` reports errors, you have invalid JSON.

---

### Settings not working?

**Enable debug mode to see what's happening:**
```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

**Check logs when OpenCode starts.**

---

### Want to reset to defaults?

**Remove your config:**
```bash
# Backup first
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup

# Edit to remove audio_notifications section
# Or delete the file entirely
```

---

## Need Help?

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Open an Issue](https://github.com/IFAKA/oc-notify/issues/new)
