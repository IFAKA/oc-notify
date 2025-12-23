# Troubleshooting

Common issues and solutions for oc-notify.

## Quick Diagnostics

### Test Audio Manually

Run the test script to check your audio setup:

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/main/scripts/test-audio.sh | bash
```

Or if you've cloned the repo:

```bash
./scripts/test-audio.sh
```

This will test all available audio methods on your system.

---

## Common Issues

### No sound at all

#### 1. Test terminal bell

```bash
printf '\a'
```

**Heard a beep?** ✅ Your terminal supports audio  
**No sound?** ⬇️ Continue troubleshooting

---

#### 2. Check terminal settings

**macOS Terminal.app:**
- Terminal → Preferences → Profiles → Advanced
- Check "Audible bell"

**Ghostty:**
- Should work by default
- Check `~/.config/ghostty/config` for bell settings

**Alacritty:**
- Check `~/.config/alacritty/alacritty.yml`
- Set `bell.duration: 100`

**Kitty:**
- Check `~/.config/kitty/kitty.conf`
- Set `enable_audio_bell yes`

---

#### 3. Check system audio

**macOS:**
```bash
# Check alert volume
# System Preferences → Sound → Sound Effects → Alert volume
```

**Linux:**
```bash
# Check if sound is muted
amixer get Master

# Unmute if needed
amixer set Master unmute
```

---

#### 4. Enable debug mode

Edit `~/.config/opencode/opencode.json`:

```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

Restart OpenCode and check the logs.

**What to look for:**
```
🔊 Audio Notify Plugin v1.0.0
📱 Platform: linux
✅ Available audio methods: speaker-test, bell
🎵 Primary method: speaker-test
```

If you see errors here, that's your clue.

---

### Linux TTY Issues

#### "speaker-test: command not found"

**Install ALSA utils:**

```bash
# Arch
sudo pacman -S alsa-utils

# Debian/Ubuntu
sudo apt install alsa-utils

# Fedora
sudo dnf install alsa-utils

# openSUSE
sudo zypper install alsa-utils
```

**Verify installation:**
```bash
speaker-test -t sine -f 800 -l 1
```

---

#### "beep: command not found"

**Install beep package:**

```bash
# Arch
sudo pacman -S beep

# Debian/Ubuntu
sudo apt install beep

# Fedora
sudo dnf install beep
```

**Note:** `beep` requires proper permissions. If it doesn't work, use `speaker-test` instead.

---

#### No sound in pure TTY

**Check PC speaker module:**

```bash
# Load module
sudo modprobe pcspkr

# Make permanent
echo "pcspkr" | sudo tee /etc/modules-load.d/pcspkr.conf
```

**Check ALSA:**

```bash
# List sound cards
aplay -l

# Test ALSA
speaker-test -t sine -f 800 -l 1 -c 2
```

---

### macOS Issues

#### "afplay: command not found"

This shouldn't happen on macOS - `afplay` is built-in.

**Verify:**
```bash
which afplay
# Should output: /usr/bin/afplay
```

If missing, your macOS installation might be corrupted.

**Workaround:** Use terminal bell:
```json
{
  "audio_notifications": {
    "permission": { "method": "bell" },
    "completion": { "method": "bell" }
  }
}
```

---

#### Sounds play but are too quiet

**Check alert volume:**
- System Preferences → Sound → Sound Effects
- Increase "Alert volume"

---

### Windows Issues

#### PowerShell beep not working

**Test manually:**
```powershell
[console]::beep(1000,150)
```

**If that works but plugin doesn't:**
- Enable debug mode
- Check logs for errors

**If that doesn't work:**
- Check Windows sound settings
- Ensure system sounds are enabled

---

### Plugin Not Loading

#### Check OpenCode version

```bash
opencode --version
```

oc-notify requires OpenCode with plugin support.

---

#### Check plugin file location

```bash
ls -la ~/.config/opencode/plugin/audio-notify.js
```

**File should exist and be readable.**

**Fix if missing:**
```bash
# Re-run installer
curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/main/scripts/install.sh | bash
```

---

#### Check file permissions

```bash
ls -l ~/.config/opencode/plugin/audio-notify.js
```

**Should be readable:** `-rw-r--r--` or similar

**Fix if needed:**
```bash
chmod 644 ~/.config/opencode/plugin/audio-notify.js
```

---

### Configuration Issues

#### Config not loading

**Check JSON syntax:**
```bash
cat ~/.config/opencode/opencode.json | jq .
```

**If `jq` reports errors, your JSON is invalid.**

**Common mistakes:**
- Trailing commas
- Missing quotes
- Unmatched brackets

**Fix:**
```bash
# Backup
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup

# Fix syntax errors, or start fresh
```

---

#### Changes not taking effect

**Restart OpenCode:**

Config is only loaded when OpenCode starts, not during runtime.

```bash
# Exit OpenCode, then restart
opencode
```

---

### Sounds Too Frequent

#### Increase cooldowns

```json
{
  "audio_notifications": {
    "permission": { "cooldown": 10 },
    "completion": { "cooldown": 20 }
  }
}
```

Values are in seconds.

---

### Sounds Too Infrequent

#### Decrease cooldowns

```json
{
  "audio_notifications": {
    "permission": { "cooldown": 1 },
    "completion": { "cooldown": 2 }
  }
}
```

**Note:** Very low values might cause spam during rapid interactions.

---

### Wrong Sound Playing

#### Force specific method

```json
{
  "audio_notifications": {
    "permission": { "method": "bell" },
    "completion": { "method": "speaker-test" }
  }
}
```

**Available methods:**
- `bell` - Terminal bell (universal)
- `afplay` - macOS system sounds
- `speaker-test` - Linux ALSA tones
- `beep` - Linux PC speaker
- `paplay` - Linux PulseAudio
- `powershell-beep` - Windows PowerShell

---

## Still Having Issues?

### Enable debug mode and collect logs

1. **Enable debug:**
```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

2. **Restart OpenCode and reproduce issue**

3. **Copy the logs**

4. **Open an issue:**

[Create Issue](https://github.com/IFAKA/oc-notify/issues/new?template=bug_report.md)

**Include:**
- Your platform (macOS, Linux distro, Windows version)
- OpenCode version: `opencode --version`
- Debug logs from OpenCode startup
- What you expected vs what happened

---

## Uninstall

### Temporary disable

```json
{
  "audio_notifications": {
    "enabled": false
  }
}
```

---

### Complete removal

```bash
# Remove plugin
rm ~/.config/opencode/plugin/audio-notify.js

# Remove config (optional)
# Edit ~/.config/opencode/opencode.json and remove audio_notifications section
```

---

## Getting Help

- **Documentation:** [README.md](../README.md)
- **Configuration:** [CONFIGURATION.md](CONFIGURATION.md)
- **Issues:** [GitHub Issues](https://github.com/IFAKA/oc-notify/issues)
- **Discussions:** [GitHub Discussions](https://github.com/IFAKA/oc-notify/discussions)
