# Development Guide

Contributing to oc-notify.

## Project Structure

```
oc-notify/
├── audio-notify.js           # Main plugin file (~400 lines)
├── scripts/
│   ├── install.sh           # Installation script
│   └── test-audio.sh        # Audio testing utility
├── docs/
│   ├── INSTALLATION.md      # Installation guide
│   ├── CONFIGURATION.md     # Configuration reference
│   ├── TROUBLESHOOTING.md   # Troubleshooting guide
│   └── DEVELOPMENT.md       # This file
└── examples/
    └── opencode.json.example # Example configuration
```

---

## Development Setup

### Prerequisites

- OpenCode installed
- Node.js/Bun (for testing)
- Git

### Clone Repository

```bash
git clone https://github.com/IFAKA/oc-notify.git
cd oc-notify
```

### Install Locally for Testing

```bash
# Create symlink to your OpenCode plugin directory
ln -sf "$(pwd)/audio-notify.js" ~/.config/opencode/plugin/audio-notify.js
```

Now changes to `audio-notify.js` will be reflected immediately when you restart OpenCode.

---

## Code Structure

### Main Components

**1. Audio Method Registry** (Lines ~10-70)
- Defines all supported audio methods
- Platform compatibility
- Priority ordering

**2. Detection System** (Lines ~80-120)
- Platform detection
- Command availability checking
- Method prioritization

**3. Playback Functions** (Lines ~130-280)
- Individual playback implementations
- Error handling
- Fallback chain

**4. Cooldown System** (Lines ~290-330)
- Spam prevention
- Timestamp tracking

**5. Configuration System** (Lines ~340-390)
- Config loading
- Default values
- Config merging

**6. Plugin Export** (Lines ~400-450)
- OpenCode plugin interface
- Event hooks
- Initialization

---

## Adding a New Audio Method

### Example: Adding SOX support

**1. Add to registry:**

```javascript
const AUDIO_METHODS = {
  // ... existing methods
  
  'sox': {
    platform: 'linux',
    check: 'sox',
    priority: 7,
    type: 'tone',
    description: 'SOX audio player'
  }
}
```

**2. Implement playback function:**

```javascript
async function playSox($, type, config) {
  const defaults = {
    permission: { freq: 1000, duration: 0.15 },
    completion: { freq: 600, duration: 0.25 }
  }
  
  const settings = config?.[type]?.tone || defaults[type]
  const { freq, duration } = settings
  
  // SOX play sine wave
  await $`sox -n -t alsa default synth ${duration} sine ${freq}`.quiet()
}
```

**3. Add to playback switch:**

```javascript
async function playSound($, type, methods, config) {
  for (const method of methods) {
    try {
      switch(method) {
        // ... existing cases
        
        case 'sox':
          await playSox($, type, config)
          return true
        
        // ... rest
      }
    } catch (error) {
      continue
    }
  }
  
  return false
}
```

**4. Test:**

```bash
# Restart OpenCode
opencode

# Should see SOX in available methods if installed
```

**5. Document:**

Update README.md and CONFIGURATION.md with the new method.

---

## Testing

### Manual Testing

**1. Install locally:**

```bash
ln -sf "$(pwd)/audio-notify.js" ~/.config/opencode/plugin/audio-notify.js
```

**2. Enable debug mode:**

```json
{
  "audio_notifications": {
    "debug": true
  }
}
```

**3. Start OpenCode and test:**

```bash
opencode
```

**4. Trigger events:**

- Ask OpenCode to run a bash command (permission)
- Wait for completion (completion sound)

---

### Test Script

Run the audio test script:

```bash
./scripts/test-audio.sh
```

This tests all audio methods available on your system.

---

### Platform Testing

Ideally, test on multiple platforms:

- ✅ macOS (Ghostty, Terminal.app)
- ✅ Linux Desktop (GNOME, KDE)
- ✅ Linux TTY (Arch, Debian)
- ✅ Windows (PowerShell)
- ✅ WSL

---

## Code Style

### Guidelines

- Use clear, descriptive variable names
- Comment complex logic
- Keep functions focused and small
- Use async/await consistently
- Handle errors gracefully
- Don't crash the plugin on errors

### Example

**Good:**
```javascript
async function detectAvailableAudio($, platform) {
  const available = []
  
  // Terminal bell is always available
  available.push({ name: 'bell', priority: 1 })
  
  // Test platform-specific methods
  for (const [name, method] of Object.entries(AUDIO_METHODS)) {
    if (method.platform === platform || method.platform === 'all') {
      if (await commandExists($, method.check)) {
        available.push({ name, priority: method.priority })
      }
    }
  }
  
  return available.sort((a, b) => b.priority - a.priority)
}
```

**Bad:**
```javascript
async function detect($, p) {
  let a = []
  a.push({ name: 'bell', priority: 1 })
  for (let [n, m] of Object.entries(AUDIO_METHODS)) {
    if (m.platform === p || m.platform === 'all')
      if (await commandExists($, m.check))
        a.push({ name: n, priority: m.priority })
  }
  return a.sort((x, y) => y.priority - x.priority)
}
```

---

## Documentation

### When to Update Docs

- New audio method → Update README, CONFIGURATION
- New config option → Update CONFIGURATION
- New platform support → Update INSTALLATION
- Bug fix → Update TROUBLESHOOTING
- Breaking change → Update README with migration guide

### Documentation Style

- **Clear and concise**
- **ADHD-friendly** - scannable, visual hierarchy
- **Example-driven** - show, don't just tell
- **Problem-solution format** for troubleshooting

---

## Pull Request Process

### Before Submitting

1. **Test your changes**
   - Works on your platform
   - Doesn't break existing functionality
   - Handles errors gracefully

2. **Update documentation**
   - README if user-facing
   - Comments in code
   - Relevant docs/ files

3. **Format code**
   - Consistent indentation
   - Clear variable names
   - Comments for complex logic

### PR Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- Platform tested: macOS/Linux/Windows
- OpenCode version: 1.x.x
- Test results: ✅ / ❌

## Checklist
- [ ] Code tested locally
- [ ] Documentation updated
- [ ] No breaking changes (or documented migration path)
```

---

## Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Creating a Release

**1. Update version:**

```javascript
// In audio-notify.js
console.log('🔊 Audio Notify Plugin v1.1.0')  // Update version
```

```json
// In package.json
"version": "1.1.0"  // Update version
```

**2. Update CHANGELOG:**

Create/update `CHANGELOG.md` with changes.

**3. Tag release:**

```bash
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0
```

**4. Create GitHub release:**

```bash
gh release create v1.1.0 \
  --title "v1.1.0" \
  --notes "Release notes here"
```

---

## Getting Help

- **Questions:** [GitHub Discussions](https://github.com/IFAKA/oc-notify/discussions)
- **Bugs:** [GitHub Issues](https://github.com/IFAKA/oc-notify/issues)
- **Chat:** OpenCode Discord (if available)

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
