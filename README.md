# 🔊 oc-notify

> Audio notifications for OpenCode. Get notified when permissions are requested or tasks complete.

## TL;DR

Works on macOS, Linux Desktop, Linux TTY, Windows, and WSL. Install in 30 seconds:

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

---

## The Problem

You ask OpenCode to do something, switch to another window, and forget to check back.

## The Solution

🔔 Get an audio notification when:
- OpenCode needs permission to run commands
- OpenCode finishes your task

No more constant checking!

---

## ⚡ Quick Start

### Automatic Installation (Recommended)

**Copy and paste this:**

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

**That's it!** Start OpenCode and you'll have audio notifications.

---

### Manual Installation

If you prefer to install manually:

**Step 1:** Create the plugin directory
```bash
mkdir -p ~/.config/opencode/plugin
```

**Step 2:** Download the plugin
```bash
curl -o ~/.config/opencode/plugin/audio-notify.js \
  https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js
```

**Step 3:** Restart OpenCode
```bash
opencode
```

**Done!** 🎉

---

## 🔄 Update & Uninstall

### Quick Update

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/update.sh | bash
```

### Quick Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/uninstall.sh | bash
```

**Details:** [Installation Guide](docs/INSTALLATION.md#uninstallation)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔔 **Permission Alerts** | Sound when OpenCode needs approval |
| 🎵 **Completion Sounds** | Sound when your task finishes |
| 🌍 **Cross-Platform** | macOS, Linux Desktop, Linux TTY, Windows, WSL |
| 🎯 **Zero Config** | Works immediately with smart defaults |
| 🔕 **Anti-Spam** | Smart cooldowns prevent sound spam |
| ⚙️ **Configurable** | Customize sounds, timing, everything |
| 🪶 **Lightweight** | Single file, no dependencies |

---

## 🎯 How It Works

```
  OpenCode asks permission
          ↓
      🔔 DING!
          ↓
  You switch back & approve
          ↓
    [Task runs...]
          ↓
     🎵 CHIME!
          ↓
   You check results
```

**Permission sound:** Short, attention-grabbing beep  
**Completion sound:** Pleasant chime

---

## 🔧 Platform-Specific Setup

### macOS
**You're all set!** Works out of the box with system sounds.

### Linux Desktop (GNOME/KDE/etc)
**You're all set!** Auto-detects PulseAudio/PipeWire.

### Linux TTY (Arch/Pure Console)
**For best audio quality, install ALSA utils:**

```bash
sudo pacman -S alsa-utils        # Arch
sudo apt install alsa-utils      # Debian/Ubuntu
sudo dnf install alsa-utils      # Fedora
```

**Test your audio:**
```bash
speaker-test -t sine -f 800 -l 1
```

**Heard a beep?** ✅ Perfect!  
**No sound?** See [Troubleshooting](#troubleshooting)

### Windows
**You're all set!** Uses PowerShell beep commands.

### WSL
**Works with terminal bell by default.** For better sound, configure audio forwarding.

---

## 🎉 Verify It Works

**Start OpenCode:**
```bash
opencode
```

**You should see:**
```
🔊 Audio Notify Plugin v1.0.0
📱 Platform: linux
✅ Available audio methods: speaker-test, bell
🎵 Primary method: speaker-test
```

**Test it:**
1. Ask OpenCode to run a bash command
2. 🔔 Hear a sound when permission requested
3. 🎵 Hear a sound when task completes

**Working?** 🎉 You're done!  
**Not working?** 😕 Check [Troubleshooting](#troubleshooting)

---

## ⚙️ Configuration (Optional)

The plugin works great with defaults. Only configure if you want to customize.

**Create:** `~/.config/opencode/opencode.json`

### Example 1: Disable completion sounds
```json
{
  "audio_notifications": {
    "completion": {
      "enabled": false
    }
  }
}
```

### Example 2: Use only terminal bell
```json
{
  "audio_notifications": {
    "permission": { "method": "bell" },
    "completion": { "method": "bell" }
  }
}
```

### Example 3: Adjust cooldowns
```json
{
  "audio_notifications": {
    "permission": { "cooldown": 5 },
    "completion": { "cooldown": 10 }
  }
}
```

**See all options:** [docs/CONFIGURATION.md](docs/CONFIGURATION.md)

---

## 🔧 Troubleshooting

### No sound at all?

**Test manually:**
```bash
printf '\a'
```

**Still nothing?**
- **Linux TTY:** Install `alsa-utils` (see [Platform Setup](#platform-specific-setup))
- **macOS:** Check System Preferences → Sound → Alert volume
- **All:** Enable debug mode (see below)

---

### How do I see what's happening?

**Enable debug mode:**

Edit `~/.config/opencode/opencode.json`:
```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

**Restart OpenCode** - you'll see detailed logs.

---

### Linux TTY: "speaker-test: command not found"

**Install ALSA utils:**
```bash
sudo pacman -S alsa-utils      # Arch
sudo apt install alsa-utils    # Debian/Ubuntu
sudo dnf install alsa-utils    # Fedora
```

---

### Sounds too frequent?

**Increase cooldowns:**
```json
{
  "audio_notifications": {
    "permission": { "cooldown": 10 },
    "completion": { "cooldown": 20 }
  }
}
```

---

### Disable temporarily

**Option 1: In config**
```json
{
  "audio_notifications": {
    "enabled": false
  }
}
```

**Option 2: Remove plugin**
```bash
rm ~/.config/opencode/plugin/audio-notify.js
```

---

**More help:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) or [open an issue](https://github.com/IFAKA/oc-notify/issues/new)

---

## 🧠 How It Works (Technical)

<details>
<summary><b>Click to expand technical details</b></summary>

### Detection System
On startup, the plugin:
1. Detects your platform (macOS, Linux, Windows)
2. Tests which audio methods are available
3. Picks the best one automatically
4. Falls back gracefully if methods fail

### Audio Methods (by priority)

| Platform | Best → Fallback |
|----------|-----------------|
| macOS | afplay → bell |
| Linux Desktop | paplay → speaker-test → bell |
| Linux TTY | speaker-test → beep → bell |
| Windows | powershell-beep → bell |

### Events
- `permission.updated` - Fires when OpenCode asks permission
- `session.idle` - Fires when OpenCode finishes processing

### Anti-Spam System
- Permission sounds: Max 1 per 2 seconds
- Completion sounds: Max 1 per 5 seconds

**Why?** If OpenCode requests 10 permissions rapidly, you hear 1 sound, not 10!

</details>

---

## 📋 Quick Reference

### One-Line Commands

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash

# Update
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/update.sh | bash

# Uninstall (leaves no trace)
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/uninstall.sh | bash

# Test audio
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/test-audio.sh | bash
```

### Files

```
Plugin:  ~/.config/opencode/plugin/audio-notify.js
Config:  ~/.config/opencode/opencode.json (optional)
```

### Quick Config Examples

**Disable completion sounds:**
```json
{ "audio_notifications": { "completion": { "enabled": false } } }
```

**Use only terminal bell:**
```json
{ "audio_notifications": { "permission": { "method": "bell" }, "completion": { "method": "bell" } } }
```

**Longer cooldowns:**
```json
{ "audio_notifications": { "permission": { "cooldown": 10 }, "completion": { "cooldown": 20 } } }
```

---

## 🤝 Contributing

**Bug?** [Open an issue](https://github.com/IFAKA/oc-notify/issues/new?template=bug_report.md)  
**Idea?** [Request a feature](https://github.com/IFAKA/oc-notify/issues/new?template=feature_request.md)  
**Code?** Fork, change, PR - See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)

---

## 📄 License

MIT License - See [LICENSE](LICENSE)

---

## 🙏 Credits

Created by [@IFAKA](https://github.com/IFAKA)

Inspired by the need to multitask while OpenCode works! ✨

---

## ⭐ Star This Repo

If this helps you, give it a star! ⭐ It helps others discover it.

---

<div align="center">

**Made with 🔊 for the OpenCode community**

[Documentation](docs/) • [Issues](https://github.com/IFAKA/oc-notify/issues)

</div>

---

## Support

If this project is useful to you, you can support my work:

[![Support me on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/zfaka)
