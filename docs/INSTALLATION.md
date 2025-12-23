# Installation Guide

Detailed installation instructions for all platforms.

## Quick Install (All Platforms)

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

This works on macOS, Linux, and WSL.

---

## Manual Installation

### Step-by-Step

**1. Create plugin directory:**

```bash
mkdir -p ~/.config/opencode/plugin
```

**2. Download plugin:**

```bash
curl -o ~/.config/opencode/plugin/audio-notify.js \
  https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js
```

Or using wget:

```bash
wget -O ~/.config/opencode/plugin/audio-notify.js \
  https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js
```

**3. Verify installation:**

```bash
ls -la ~/.config/opencode/plugin/audio-notify.js
```

You should see the file listed.

**4. Start OpenCode:**

```bash
opencode
```

You should see:
```
🔊 Audio Notify Plugin v1.0.0
📱 Platform: <your platform>
✅ Available audio methods: ...
```

**Done!** 🎉

---

## Platform-Specific Setup

### macOS

#### Prerequisites
- OpenCode installed
- macOS 10.10 or later

#### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

#### What You Get
- `afplay` for rich system sounds (Ping.aiff, Glass.aiff)
- Terminal bell as fallback

#### Optional: Adjust alert volume
System Preferences → Sound → Sound Effects → Alert volume

---

### Linux Desktop (Ubuntu/Debian/Fedora/etc)

#### Prerequisites
- OpenCode installed
- PulseAudio or PipeWire (usually pre-installed on desktop distros)

#### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

#### What You Get
- `paplay` for system sounds (if available)
- `speaker-test` for ALSA tones
- Terminal bell as fallback

#### Optional: Install sound files

**Ubuntu/Debian:**
```bash
sudo apt install sound-theme-freedesktop
```

**Fedora:**
```bash
sudo dnf install sound-theme-freedesktop
```

---

### Linux TTY (Arch/Pure Console)

#### Prerequisites
- OpenCode installed
- ALSA (usually pre-installed)

#### Recommended Setup

**1. Install ALSA utilities:**

```bash
# Arch
sudo pacman -S alsa-utils

# Debian/Ubuntu
sudo apt install alsa-utils

# Fedora
sudo dnf install alsa-utils
```

**2. Install the plugin:**

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

**3. Test audio:**

```bash
speaker-test -t sine -f 800 -l 1
```

**Heard a beep?** ✅ You're all set!

**No sound?** Continue with troubleshooting below.

#### Troubleshooting TTY Audio

**Enable PC speaker (if needed):**

```bash
# Load module
sudo modprobe pcspkr

# Make permanent
echo "pcspkr" | sudo tee /etc/modules-load.d/pcspkr.conf
```

**Check ALSA devices:**

```bash
# List sound cards
aplay -l

# Test default device
speaker-test -t sine -f 800 -l 1
```

**Unmute sound:**

```bash
# Check volume
amixer get Master

# Unmute if needed
amixer set Master unmute
amixer set Master 50%
```

#### What You Get
- `speaker-test` for hardware tones (best for TTY)
- `beep` for PC speaker (if installed)
- Terminal bell as fallback

---

### Windows

#### Prerequisites
- OpenCode installed
- PowerShell (pre-installed on Windows)

#### Installation

**Using PowerShell:**

```powershell
# Create directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode\plugin"

# Download plugin
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js" `
  -OutFile "$env:USERPROFILE\.config\opencode\plugin\audio-notify.js"
```

**Or use WSL and follow Linux instructions.**

#### What You Get
- PowerShell beep for tones
- Terminal bell as fallback

---

### WSL (Windows Subsystem for Linux)

#### Installation

Same as Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

#### What You Get
- Terminal bell (most reliable in WSL)
- Other methods may work depending on your WSL audio setup

#### Optional: Configure WSL Audio

For better audio in WSL, you can:
1. Use PulseAudio forwarding to Windows
2. Configure WSLg (WSL2 with GUI support)

See: [WSL Audio Guide](https://docs.microsoft.com/en-us/windows/wsl/tutorials/gui-apps#audio)

---

## Verification

### Test the Plugin

**1. Start OpenCode:**

```bash
opencode
```

**2. Look for startup message:**

```
🔊 Audio Notify Plugin v1.0.0
📱 Platform: darwin
✅ Available audio methods: afplay, bell
🎵 Primary method: afplay
```

**3. Test permission sound:**

Ask OpenCode to run a bash command. You should hear a sound when permission is requested.

**4. Test completion sound:**

After OpenCode finishes, you should hear a different sound.

---

### Run Audio Test Script

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/test-audio.sh | bash
```

This tests all available audio methods on your system.

---

## Uninstallation

### Automatic Uninstall (Recommended)

**Complete removal with no trace:**

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/uninstall.sh | bash
```

**What it removes:**
- ✅ Plugin file
- ✅ Backup files (with confirmation)
- ✅ Empty directories
- ✅ Optional: Config section (with confirmation)

**Leaves no trace!**

---

### Manual Uninstall

**1. Remove plugin:**

```bash
rm ~/.config/opencode/plugin/audio-notify.js
```

**2. Remove backups (optional):**

```bash
rm ~/.config/opencode/plugin/audio-notify.js.backup.*
```

**3. Remove config (optional):**

Edit `~/.config/opencode/opencode.json` and remove the `audio_notifications` section.

**4. Cleanup empty directories:**

```bash
# Only if empty
rmdir ~/.config/opencode/plugin 2>/dev/null
rmdir ~/.config/opencode 2>/dev/null
```

---

## Updating

### Automatic Update (Recommended)

**Update to latest version:**

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/update.sh | bash
```

**What it does:**
- ✅ Checks current vs latest version
- ✅ Backs up current version
- ✅ Downloads latest version
- ✅ Verifies installation
- ✅ Rolls back on failure

---

### Manual Update

**Re-run the installer:**

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash
```

The installer automatically backs up your existing plugin.

**Or update directly:**

```bash
# Backup existing
cp ~/.config/opencode/plugin/audio-notify.js ~/.config/opencode/plugin/audio-notify.js.backup

# Download new version
curl -o ~/.config/opencode/plugin/audio-notify.js \
  https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js
```

---

## Troubleshooting Installation

### "curl: command not found"

**Install curl:**

```bash
# Debian/Ubuntu
sudo apt install curl

# Arch
sudo pacman -S curl

# Fedora
sudo dnf install curl

# macOS (using Homebrew)
brew install curl
```

Or use wget instead:

```bash
wget -O ~/.config/opencode/plugin/audio-notify.js \
  https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js
```

---

### Permission Denied

**Check directory permissions:**

```bash
ls -la ~/.config/opencode/
```

**Fix if needed:**

```bash
chmod 755 ~/.config/opencode
chmod 755 ~/.config/opencode/plugin
```

---

### Plugin Not Loading

**Check OpenCode version:**

```bash
opencode --version
```

Ensure you're using a version that supports plugins.

**Check plugin file:**

```bash
cat ~/.config/opencode/plugin/audio-notify.js | head -5
```

Should show JavaScript code starting with `/**`.

---

## Next Steps

- **Configure:** [CONFIGURATION.md](CONFIGURATION.md)
- **Troubleshoot:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Main README:** [../README.md](../README.md)
