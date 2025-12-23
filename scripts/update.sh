#!/usr/bin/env bash

# oc-notify updater
# Updates the audio notification plugin to the latest version

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Plugin details
PLUGIN_URL="https://raw.githubusercontent.com/IFAKA/oc-notify/master/audio-notify.js"
PLUGIN_NAME="audio-notify.js"
VERSION_URL="https://raw.githubusercontent.com/IFAKA/oc-notify/master/package.json"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}🔄 oc-notify Updater${NC}"
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
# VERSION FUNCTIONS
# ============================================================================

get_installed_version() {
  local plugin_path="$1"
  
  if [[ -f "$plugin_path" ]]; then
    # Extract version from plugin file (looks for: Audio Notify Plugin v1.0.0)
    local version=$(grep -o "Audio Notify Plugin v[0-9]\+\.[0-9]\+\.[0-9]\+" "$plugin_path" 2>/dev/null | head -1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")
    echo "$version"
  fi
}

get_latest_version() {
  # Fetch latest version from package.json
  if command -v curl &> /dev/null; then
    local version=$(curl -fsSL "$VERSION_URL" 2>/dev/null | grep '"version"' | head -1 | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")
    echo "$version"
  fi
}

compare_versions() {
  local current="$1"
  local latest="$2"
  
  if [[ "$current" == "$latest" ]]; then
    return 0  # Same version
  else
    return 1  # Different version
  fi
}

# ============================================================================
# UPDATE FUNCTIONS
# ============================================================================

check_installation() {
  # Determine config directory
  if [[ -n "$XDG_CONFIG_HOME" ]]; then
    CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
  else
    CONFIG_DIR="$HOME/.config/opencode"
  fi
  
  PLUGIN_DIR="$CONFIG_DIR/plugin"
  PLUGIN_PATH="$PLUGIN_DIR/$PLUGIN_NAME"
  
  if [[ ! -f "$PLUGIN_PATH" ]]; then
    print_error "oc-notify is not installed"
    echo ""
    print_info "To install:"
    echo "  curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash"
    echo ""
    exit 1
  fi
}

backup_current() {
  local plugin_path="$1"
  local backup_path="${plugin_path}.backup.$(date +%s)"
  
  print_info "Creating backup..."
  cp "$plugin_path" "$backup_path"
  print_success "Backup created: $(basename "$backup_path")"
  
  echo "$backup_path"
}

download_latest() {
  local plugin_path="$1"
  
  print_info "Downloading latest version..."
  
  if command -v curl &> /dev/null; then
    curl -fsSL "$PLUGIN_URL" -o "$plugin_path"
  elif command -v wget &> /dev/null; then
    wget -q "$PLUGIN_URL" -O "$plugin_path"
  else
    print_error "Neither curl nor wget found"
    exit 1
  fi
  
  print_success "Download complete"
}

verify_update() {
  local plugin_path="$1"
  
  if [[ -f "$plugin_path" ]] && [[ -s "$plugin_path" ]]; then
    # Check if file contains expected content
    if grep -q "AudioNotify" "$plugin_path" 2>/dev/null; then
      return 0
    fi
  fi
  
  return 1
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  print_header
  
  # Check if installed
  check_installation
  
  print_info "Checking for updates..."
  echo ""
  
  # Get versions
  CURRENT_VERSION=$(get_installed_version "$PLUGIN_PATH")
  LATEST_VERSION=$(get_latest_version)
  
  if [[ -n "$CURRENT_VERSION" ]]; then
    print_info "Installed version: v$CURRENT_VERSION"
  else
    print_warning "Could not detect installed version"
  fi
  
  if [[ -n "$LATEST_VERSION" ]]; then
    print_info "Latest version:    v$LATEST_VERSION"
  else
    print_warning "Could not fetch latest version"
  fi
  
  echo ""
  
  # Compare versions
  if [[ -n "$CURRENT_VERSION" ]] && [[ -n "$LATEST_VERSION" ]]; then
    if compare_versions "$CURRENT_VERSION" "$LATEST_VERSION"; then
      print_success "You're already on the latest version! 🎉"
      echo ""
      print_info "No update needed"
      exit 0
    fi
  fi
  
  # Proceed with update
  print_info "Update available!"
  echo ""
  
  # Backup current version
  BACKUP_PATH=$(backup_current "$PLUGIN_PATH")
  
  # Download latest
  echo ""
  download_latest "$PLUGIN_PATH"
  
  # Verify update
  echo ""
  print_info "Verifying update..."
  
  if verify_update "$PLUGIN_PATH"; then
    print_success "Update verified!"
    
    # Get new version
    NEW_VERSION=$(get_installed_version "$PLUGIN_PATH")
    
    # Success message
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Update complete! 🎉${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [[ -n "$NEW_VERSION" ]]; then
      print_success "Updated to version: v$NEW_VERSION"
    fi
    
    echo ""
    print_info "Previous version backed up to:"
    print_info "$(basename "$BACKUP_PATH")"
    echo ""
    print_info "Restart OpenCode to use the new version:"
    echo "  opencode"
    echo ""
    
  else
    print_error "Update verification failed"
    echo ""
    print_info "Restoring from backup..."
    mv "$BACKUP_PATH" "$PLUGIN_PATH"
    print_success "Restored previous version"
    echo ""
    print_error "Update failed - please try again or report an issue"
    echo "  https://github.com/IFAKA/oc-notify/issues"
    exit 1
  fi
}

# Run main
main
