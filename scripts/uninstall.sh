#!/usr/bin/env bash

# oc-notify uninstaller
# Removes the audio notification plugin from OpenCode
# Leaves no trace!

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Plugin details
PLUGIN_NAME="audio-notify.js"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}🗑️  oc-notify Uninstaller${NC}"
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

confirm() {
  local prompt="$1"
  local response
  
  echo -e "${YELLOW}$prompt${NC}"
  read -p "Continue? (y/N): " response
  
  case "$response" in
    [yY][eE][sS]|[yY]) 
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# ============================================================================
# DETECTION FUNCTIONS
# ============================================================================

find_plugin_locations() {
  # Determine config directory
  if [[ -n "$XDG_CONFIG_HOME" ]]; then
    CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
  else
    CONFIG_DIR="$HOME/.config/opencode"
  fi
  
  PLUGIN_DIR="$CONFIG_DIR/plugin"
  PLUGIN_PATH="$PLUGIN_DIR/$PLUGIN_NAME"
}

check_installation() {
  if [[ -f "$PLUGIN_PATH" ]]; then
    print_info "Plugin found at: $PLUGIN_PATH"
    return 0
  else
    print_warning "Plugin not found at: $PLUGIN_PATH"
    return 1
  fi
}

find_backups() {
  local backups=()
  
  if [[ -d "$PLUGIN_DIR" ]]; then
    while IFS= read -r backup; do
      backups+=("$backup")
    done < <(find "$PLUGIN_DIR" -name "audio-notify.js.backup.*" 2>/dev/null)
  fi
  
  echo "${backups[@]}"
}

find_config() {
  local config_file="$CONFIG_DIR/opencode.json"
  
  if [[ -f "$config_file" ]]; then
    # Check if config contains audio_notifications
    if grep -q "audio_notifications" "$config_file" 2>/dev/null; then
      echo "$config_file"
      return 0
    fi
  fi
  
  return 1
}

# ============================================================================
# REMOVAL FUNCTIONS
# ============================================================================

remove_plugin() {
  if [[ -f "$PLUGIN_PATH" ]]; then
    print_info "Removing plugin..."
    rm "$PLUGIN_PATH"
    print_success "Plugin removed"
    return 0
  else
    print_warning "Plugin file not found (already removed?)"
    return 1
  fi
}

remove_backups() {
  local backups=($@)
  
  if [[ ${#backups[@]} -gt 0 ]]; then
    echo ""
    print_info "Found ${#backups[@]} backup file(s)"
    
    if confirm "Remove backup files?"; then
      for backup in "${backups[@]}"; do
        rm "$backup"
        print_success "Removed: $(basename "$backup")"
      done
    else
      print_info "Keeping backup files"
    fi
  fi
}

remove_config() {
  local config_file="$1"
  
  if [[ -n "$config_file" ]]; then
    echo ""
    print_warning "Configuration found in: $config_file"
    print_warning "This contains your audio_notifications settings"
    
    if confirm "Remove audio_notifications config section?"; then
      # Create backup of config
      local backup_config="${config_file}.backup.$(date +%s)"
      cp "$config_file" "$backup_config"
      print_info "Config backed up to: $backup_config"
      
      # Remove audio_notifications section (simple approach - inform user)
      print_warning "Please manually remove the 'audio_notifications' section from:"
      print_warning "$config_file"
      echo ""
      print_info "Or restore the entire config from backup if needed:"
      print_info "mv $backup_config $config_file"
    else
      print_info "Keeping configuration"
    fi
  fi
}

cleanup_empty_dirs() {
  # Remove plugin directory if empty
  if [[ -d "$PLUGIN_DIR" ]] && [[ -z "$(ls -A "$PLUGIN_DIR")" ]]; then
    rmdir "$PLUGIN_DIR"
    print_success "Removed empty plugin directory"
  fi
  
  # Remove config directory if empty
  if [[ -d "$CONFIG_DIR" ]] && [[ -z "$(ls -A "$CONFIG_DIR")" ]]; then
    rmdir "$CONFIG_DIR"
    print_success "Removed empty config directory"
  fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  print_header
  
  # Find locations
  find_plugin_locations
  
  # Check if installed
  if ! check_installation; then
    echo ""
    print_warning "oc-notify doesn't appear to be installed"
    
    # Check for backups anyway
    backups=($(find_backups))
    if [[ ${#backups[@]} -gt 0 ]]; then
      remove_backups "${backups[@]}"
    fi
    
    echo ""
    print_info "Nothing to uninstall"
    exit 0
  fi
  
  echo ""
  
  # Confirm uninstallation
  if ! confirm "⚠️  This will remove oc-notify from OpenCode"; then
    print_info "Uninstall cancelled"
    exit 0
  fi
  
  echo ""
  
  # Remove plugin
  if remove_plugin; then
    REMOVED_PLUGIN=true
  fi
  
  # Find and handle backups
  backups=($(find_backups))
  remove_backups "${backups[@]}"
  
  # Find and handle config
  config_file=$(find_config)
  if [[ -n "$config_file" ]]; then
    remove_config "$config_file"
  fi
  
  # Cleanup empty directories
  echo ""
  cleanup_empty_dirs
  
  # Success message
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ Uninstall complete!${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  if [[ "$REMOVED_PLUGIN" == "true" ]]; then
    print_info "oc-notify has been removed from OpenCode"
    echo ""
    print_info "To reinstall:"
    echo "  curl -fsSL https://raw.githubusercontent.com/IFAKA/oc-notify/master/scripts/install.sh | bash"
  fi
  
  echo ""
}

# Run main
main
