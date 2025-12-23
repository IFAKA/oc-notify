/**
 * oc-notify - Audio notifications plugin for OpenCode
 * 
 * Plays audio notifications when:
 * - OpenCode requests permission to execute commands
 * - OpenCode finishes processing tasks
 * 
 * Works across macOS, Linux Desktop, Linux TTY, Windows, and WSL
 * with automatic fallback chain for maximum compatibility.
 */

// ============================================================================
// AUDIO METHOD REGISTRY
// ============================================================================

/**
 * Registry of available audio playback methods with metadata
 * Methods are tried in priority order (highest first)
 */
const AUDIO_METHODS = {
  // macOS - System sounds
  'afplay': {
    platform: 'darwin',
    check: 'afplay',
    priority: 10,
    type: 'file',
    description: 'macOS system sound player'
  },
  
  // Linux - PulseAudio (desktop environments)
  'paplay': {
    platform: 'linux',
    check: 'paplay',
    priority: 9,
    type: 'file',
    description: 'PulseAudio sound player'
  },
  
  // Linux - ALSA (works in TTY!)
  'speaker-test': {
    platform: 'linux',
    check: 'speaker-test',
    priority: 8,
    type: 'tone',
    description: 'ALSA tone generator (TTY compatible)'
  },
  
  // Linux - ALSA player
  'aplay': {
    platform: 'linux',
    check: 'aplay',
    priority: 7,
    type: 'file',
    description: 'ALSA sound player'
  },
  
  // Linux - PC speaker (works in TTY!)
  'beep': {
    platform: 'linux',
    check: 'beep',
    priority: 6,
    type: 'tone',
    description: 'PC speaker beep (TTY compatible)'
  },
  
  // Windows - PowerShell beep
  'powershell-beep': {
    platform: 'win32',
    check: 'powershell',
    priority: 5,
    type: 'tone',
    description: 'Windows PowerShell beep'
  },
  
  // Universal fallback - Terminal bell (ALWAYS works)
  'bell': {
    platform: 'all',
    check: null, // Always available
    priority: 1,
    type: 'bell',
    description: 'Terminal bell (universal)'
  }
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Sleep helper for async delays
 */
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

/**
 * Check if a command exists on the system
 */
async function commandExists($, command) {
  try {
    await $`which ${command}`.quiet()
    return true
  } catch (e) {
    return false
  }
}

// ============================================================================
// DETECTION SYSTEM
// ============================================================================

/**
 * Detect available audio methods on the current system
 * Returns array of method names sorted by priority (best first)
 */
async function detectAvailableAudio($, platform) {
  const available = []
  
  // Terminal bell is always available
  available.push({ name: 'bell', priority: AUDIO_METHODS['bell'].priority })
  
  // Test platform-specific methods
  for (const [name, method] of Object.entries(AUDIO_METHODS)) {
    // Skip universal methods (already added)
    if (method.platform === 'all') continue
    
    // Skip methods not for this platform
    if (method.platform !== platform) continue
    
    // Check if command exists
    if (method.check && await commandExists($, method.check)) {
      available.push({ name, priority: method.priority })
    }
  }
  
  // Sort by priority (highest first) and extract names
  return available
    .sort((a, b) => b.priority - a.priority)
    .map(m => m.name)
}

// ============================================================================
// PLAYBACK FUNCTIONS
// ============================================================================

/**
 * Play terminal bell (universal fallback)
 * Different patterns for different event types
 */
async function playBell($, type) {
  if (type === 'permission') {
    // Single beep for permission
    await $`printf '\a'`.quiet()
  } else if (type === 'completion') {
    // Double beep for completion (more distinctive)
    await $`printf '\a'`.quiet()
    await sleep(100)
    await $`printf '\a'`.quiet()
  }
}

/**
 * Play sound using macOS afplay
 */
async function playAfplay($, type) {
  const sounds = {
    permission: '/System/Library/Sounds/Ping.aiff',
    completion: '/System/Library/Sounds/Glass.aiff'
  }
  
  const soundFile = sounds[type]
  if (!soundFile) throw new Error(`Unknown type: ${type}`)
  
  await $`afplay ${soundFile}`.quiet()
}

/**
 * Play tone using ALSA speaker-test (Linux TTY compatible)
 */
async function playSpeakerTest($, type, config) {
  const defaults = {
    permission: { freq: 1000, duration: 0.15 },  // High pitch, short
    completion: { freq: 600, duration: 0.25 }    // Low pitch, longer
  }
  
  // Allow config override
  const settings = config?.[type]?.tone || defaults[type]
  const { freq, duration } = settings
  
  // speaker-test generates continuous tone, use timeout to limit duration
  // -t sine: sine wave
  // -f freq: frequency in Hz
  // -l 1: play once
  // 2>/dev/null: suppress stderr output
  await $`timeout ${duration}s speaker-test -t sine -f ${freq} -l 1 2>/dev/null`.quiet()
}

/**
 * Play beep using Linux beep command (PC speaker)
 */
async function playBeep($, type, config) {
  const defaults = {
    permission: { freq: 1000, duration: 150 },
    completion: { freq: 600, duration: 200 }
  }
  
  const settings = config?.[type]?.tone || defaults[type]
  const { freq, duration } = settings
  
  // beep -f frequency -l length_in_ms
  await $`beep -f ${freq} -l ${duration} 2>/dev/null`.quiet()
}

/**
 * Play sound using PulseAudio paplay (Linux desktop)
 */
async function playPaplay($, type) {
  // Try common sound file locations
  const soundPaths = {
    permission: [
      '/usr/share/sounds/freedesktop/stereo/message.oga',
      '/usr/share/sounds/freedesktop/stereo/bell.oga',
      '/usr/share/sounds/freedesktop/stereo/message-new-instant.oga'
    ],
    completion: [
      '/usr/share/sounds/freedesktop/stereo/complete.oga',
      '/usr/share/sounds/freedesktop/stereo/service-login.oga',
      '/usr/share/sounds/freedesktop/stereo/dialog-information.oga'
    ]
  }
  
  const paths = soundPaths[type]
  if (!paths) throw new Error(`Unknown type: ${type}`)
  
  // Try each path until one works
  for (const path of paths) {
    try {
      await $`paplay ${path} 2>/dev/null`.quiet()
      return // Success!
    } catch (e) {
      // Try next path
      continue
    }
  }
  
  // No sound files found
  throw new Error('No sound files available')
}

/**
 * Play beep using Windows PowerShell
 */
async function playPowershellBeep($, type, config) {
  const defaults = {
    permission: { freq: 1000, duration: 150 },
    completion: { freq: 600, duration: 250 }
  }
  
  const settings = config?.[type]?.tone || defaults[type]
  const { freq, duration } = settings
  
  await $`powershell -c "[console]::beep(${freq},${duration})"`.quiet()
}

/**
 * Play sound using specified method with fallback chain
 */
async function playSound($, type, methods, config) {
  // Try each method in order until one works
  for (const method of methods) {
    try {
      switch(method) {
        case 'afplay':
          await playAfplay($, type)
          return true
        
        case 'speaker-test':
          await playSpeakerTest($, type, config)
          return true
        
        case 'beep':
          await playBeep($, type, config)
          return true
        
        case 'paplay':
          await playPaplay($, type)
          return true
        
        case 'powershell-beep':
          await playPowershellBeep($, type, config)
          return true
        
        case 'bell':
          await playBell($, type)
          return true
        
        default:
          // Unknown method, skip
          continue
      }
    } catch (error) {
      // Method failed, try next one
      if (config.debug) {
        console.log(`⚠️  Method ${method} failed:`, error.message)
      }
      continue
    }
  }
  
  // All methods failed
  return false
}

// ============================================================================
// COOLDOWN SYSTEM
// ============================================================================

/**
 * Cooldown state to prevent sound spam
 */
const cooldowns = {
  permission: {
    duration: 2000,  // 2 seconds
    lastPlayed: 0
  },
  completion: {
    duration: 5000,  // 5 seconds
    lastPlayed: 0
  }
}

/**
 * Play sound with cooldown check to prevent spam
 */
async function playSoundWithCooldown($, type, methods, config) {
  const now = Date.now()
  const cooldown = cooldowns[type]
  
  // Get configured cooldown duration (in seconds, convert to ms)
  const configuredDuration = config?.[type]?.cooldown 
    ? config[type].cooldown * 1000 
    : cooldown.duration
  
  // Check if still in cooldown period
  if (now - cooldown.lastPlayed < configuredDuration) {
    if (config.debug) {
      console.log(`🔇 ${type} sound skipped (cooldown active)`)
    }
    return
  }
  
  // Play sound
  const success = await playSound($, type, methods, config)
  
  if (success) {
    // Update last played time
    cooldown.lastPlayed = now
    
    if (config.debug) {
      console.log(`🔊 ${type} sound played`)
    }
  } else {
    if (config.debug) {
      console.log(`⚠️  ${type} sound failed (all methods exhausted)`)
    }
  }
}

// ============================================================================
// CONFIGURATION SYSTEM
// ============================================================================

/**
 * Default configuration
 */
const defaultConfig = {
  enabled: true,
  debug: false,
  
  permission: {
    enabled: true,
    method: 'auto',      // Auto-detect best method
    cooldown: 2,         // seconds
    tone: {
      freq: 1000,
      duration: 150
    },
    bellPattern: 'single'
  },
  
  completion: {
    enabled: true,
    method: 'auto',
    cooldown: 5,         // seconds
    tone: {
      freq: 600,
      duration: 250
    },
    bellPattern: 'double'
  }
}

/**
 * Deep merge two objects
 */
function mergeConfig(defaults, user) {
  const result = { ...defaults }
  
  for (const key in user) {
    if (user[key] && typeof user[key] === 'object' && !Array.isArray(user[key])) {
      result[key] = mergeConfig(defaults[key] || {}, user[key])
    } else {
      result[key] = user[key]
    }
  }
  
  return result
}

/**
 * Load configuration from opencode.json
 */
async function loadConfig() {
  try {
    const homeDir = process.env.HOME || process.env.USERPROFILE
    const configPath = `${homeDir}/.config/opencode/opencode.json`
    
    // Try to read config file
    const fs = await import('fs/promises')
    const configFile = await fs.readFile(configPath, 'utf-8')
    const parsed = JSON.parse(configFile)
    
    // Merge user config with defaults
    const userConfig = parsed.audio_notifications || {}
    return mergeConfig(defaultConfig, userConfig)
  } catch (e) {
    // No config file or parse error - use defaults
    return defaultConfig
  }
}

// ============================================================================
// MAIN PLUGIN EXPORT
// ============================================================================

/**
 * OpenCode plugin entry point
 */
export const AudioNotify = async ({ $, directory }) => {
  // Initialize
  console.log('🔊 Audio Notify Plugin v1.0.0')
  
  // Detect platform
  const platform = process.platform
  console.log(`📱 Platform: ${platform}`)
  
  // Load configuration
  const config = await loadConfig()
  
  if (!config.enabled) {
    console.log('⏸️  Audio notifications disabled in config')
    return {
      event: async () => {} // No-op
    }
  }
  
  // Detect available audio methods
  const availableMethods = await detectAvailableAudio($, platform)
  
  if (availableMethods.length === 0) {
    console.log('⚠️  No audio methods available')
    return {
      event: async () => {}
    }
  }
  
  console.log(`✅ Available audio methods: ${availableMethods.join(', ')}`)
  console.log(`🎵 Primary method: ${availableMethods[0]}`)
  
  if (config.debug) {
    console.log('⚙️  Config:', JSON.stringify(config, null, 2))
  }
  
  // Return plugin hooks
  return {
    event: async ({ event }) => {
      // Permission requested
      if (event.type === 'permission.updated' && config.permission.enabled) {
        await playSoundWithCooldown($, 'permission', availableMethods, config)
      }
      
      // Task completed (with small delay to ensure truly idle)
      if (event.type === 'session.idle' && config.completion.enabled) {
        setTimeout(async () => {
          await playSoundWithCooldown($, 'completion', availableMethods, config)
        }, 1000)
      }
    }
  }
}
