#!/usr/bin/env bash

# oc-notify installer
# Installs the audio notification plugin for OpenCode

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Plugin details
PLUGIN_URL="https://raw.githubusercontent.com/IFAKA/oc-notify/main/audio-notify.js"
PLUGIN_NAME="audio-notify.js"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}🔊 oc-notify Installer${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================================================
# DETECTION FUNCTIONS
# ============================================================================

check_opencode() {
  if command -v opencode &> /dev/null; then
    OPENCODE_PATH=$(which opencode)
    print_success "OpenCode found: $OPENCODE_PATH"
    return 0
  else
    print_error "OpenCode not found"
    echo ""
    echo "Please install OpenCode first:"
    echo "  https://opencode.ai"
    echo ""
    exit 1
  fi
}

detect_platform() {
  case "$(uname -s)" in
    Darwin*)
      PLATFORM="macOS"
      ;;
    Linux*)
      PLATFORM="Linux"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      PLATFORM="Windows"
      ;;
    *)
      PLATFORM="Unknown"
      ;;
  esac
  
  print_success "Platform detected: $PLATFORM"
}

test_audio_methods() {
  echo ""
  echo -e "${BLUE}🔍 Testing audio capabilities...${NC}"
  
  local methods_found=()
  
  # Test terminal bell (always available)
  methods_found+=("Terminal bell")
  
  # Test platform-specific methods
  if [[ "$PLATFORM" == "macOS" ]]; then
    if command -v afplay &> /dev/null; then
      methods_found+=("afplay")
    fi
  elif [[ "$PLATFORM" == "Linux" ]]; then
    if command -v paplay &> /dev/null; then
      methods_found+=("paplay")
    fi
    if command -v speaker-test &> /dev/null; then
      methods_found+=("speaker-test")
    fi
    if command -v aplay &> /dev/null; then
      methods_found+=("aplay")
    fi
    if command -v beep &> /dev/null; then
      methods_found+=("beep")
    fi
  elif [[ "$PLATFORM" == "Windows" ]]; then
    if command -v powershell &> /dev/null; then
      methods_found+=("PowerShell")
    fi
  fi
  
  # Print found methods
  for method in "${methods_found[@]}"; do
    print_success "$method: Available"
  done
  
  # Determine primary method
  if [[ "${#methods_found[@]}" -gt 1 ]]; then
    PRIMARY_METHOD="${methods_found[1]}"
  else
    PRIMARY_METHOD="${methods_found[0]}"
  fi
  
  echo ""
  print_success "Primary method: $PRIMARY_METHOD"
  
  # Platform-specific recommendations
  if [[ "$PLATFORM" == "Linux" ]]; then
    if ! command -v speaker-test &> /dev/null; then
      echo ""
      print_warning "For best audio quality in TTY, install alsa-utils:"
      echo "  Arch:        sudo pacman -S alsa-utils"
      echo "  Debian/Ubuntu: sudo apt install alsa-utils"
      echo "  Fedora:      sudo dnf install alsa-utils"
    fi
  fi
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

setup_directories() {
  # Determine config directory
  if [[ -n "$XDG_CONFIG_HOME" ]]; then
    CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
  else
    CONFIG_DIR="$HOME/.config/opencode"
  fi
  
  PLUGIN_DIR="$CONFIG_DIR/plugin"
  
  print_info "Installing to: $PLUGIN_DIR"
  
  # Create directories if they don't exist
  mkdir -p "$PLUGIN_DIR"
}

backup_existing() {
  local plugin_path="$PLUGIN_DIR/$PLUGIN_NAME"
  
  if [[ -f "$plugin_path" ]]; then
    local backup_path="${plugin_path}.backup.$(date +%s)"
    print_warning "Existing plugin found, backing up to:"
    echo "  $backup_path"
    mv "$plugin_path" "$backup_path"
  fi
}

download_plugin() {
  local plugin_path="$PLUGIN_DIR/$PLUGIN_NAME"
  
  echo ""
  echo -e "${BLUE}⬇️  Downloading plugin...${NC}"
  
  if command -v curl &> /dev/null; then
    curl -fsSL "$PLUGIN_URL" -o "$plugin_path"
  elif command -v wget &> /dev/null; then
    wget -q "$PLUGIN_URL" -O "$plugin_path"
  else
    print_error "Neither curl nor wget found"
    echo "Please install curl or wget and try again"
    exit 1
  fi
  
  print_success "Plugin downloaded!"
}

verify_installation() {
  local plugin_path="$PLUGIN_DIR/$PLUGIN_NAME"
  
  if [[ -f "$plugin_path" ]] && [[ -s "$plugin_path" ]]; then
    print_success "Installation verified!"
    return 0
  else
    print_error "Installation failed - plugin file not found or empty"
    return 1
  fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  print_header
  
  # Pre-flight checks
  check_opencode
  detect_platform
  
  echo ""
  
  # Setup
  setup_directories
  backup_existing
  download_plugin
  
  # Verify
  if ! verify_installation; then
    exit 1
  fi
  
  # Test audio
  test_audio_methods
  
  # Success message
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ Installation complete! 🎉${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BLUE}🚀 Next steps:${NC}"
  echo "  1. Start OpenCode: opencode"
  echo "  2. Trigger a permission request"
  echo "  3. Listen for the sound! 🔔"
  echo ""
  echo -e "${BLUE}📖 Documentation:${NC}"
  echo "  https://github.com/IFAKA/oc-notify"
  echo ""
  echo -e "${BLUE}⚙️  Configuration (optional):${NC}"
  echo "  https://github.com/IFAKA/oc-notify#configuration"
  echo ""
  echo "Happy coding! 💻"
  echo ""
}

# Run main
main
