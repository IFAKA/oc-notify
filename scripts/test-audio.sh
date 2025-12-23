#!/usr/bin/env bash

# oc-notify audio testing utility
# Tests available audio methods on your system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔊 oc-notify Audio Tester${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect platform
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

echo -e "${BLUE}📱 Platform: $PLATFORM${NC}"
echo ""

# Test functions
test_method() {
  local name="$1"
  local test_command="$2"
  
  echo -n "Testing $name... "
  
  if eval "$test_command" &> /dev/null; then
    echo -e "${GREEN}✅ Works!${NC}"
    return 0
  else
    echo -e "${RED}❌ Failed${NC}"
    return 1
  fi
}

# Terminal bell (always available)
echo -e "${BLUE}🔔 Testing terminal bell${NC}"
test_method "Single beep" "printf '\a'"
sleep 0.5
test_method "Double beep" "printf '\a' && sleep 0.1 && printf '\a'"
echo ""

# Platform-specific tests
if [[ "$PLATFORM" == "macOS" ]]; then
  echo -e "${BLUE}🍎 Testing macOS methods${NC}"
  
  if command -v afplay &> /dev/null; then
    test_method "afplay (Ping)" "afplay /System/Library/Sounds/Ping.aiff"
    sleep 0.5
    test_method "afplay (Glass)" "afplay /System/Library/Sounds/Glass.aiff"
  else
    echo -e "${YELLOW}⚠️  afplay not found (should be available on macOS)${NC}"
  fi
  
elif [[ "$PLATFORM" == "Linux" ]]; then
  echo -e "${BLUE}🐧 Testing Linux methods${NC}"
  
  # speaker-test (ALSA)
  if command -v speaker-test &> /dev/null; then
    test_method "speaker-test (1000 Hz)" "timeout 0.15s speaker-test -t sine -f 1000 -l 1 2>/dev/null"
    sleep 0.5
    test_method "speaker-test (600 Hz)" "timeout 0.25s speaker-test -t sine -f 600 -l 1 2>/dev/null"
  else
    echo -e "${YELLOW}⚠️  speaker-test not found${NC}"
    echo "   Install: sudo pacman -S alsa-utils  # Arch"
    echo "            sudo apt install alsa-utils  # Debian/Ubuntu"
  fi
  
  echo ""
  
  # beep
  if command -v beep &> /dev/null; then
    test_method "beep (1000 Hz)" "beep -f 1000 -l 150 2>/dev/null"
    sleep 0.5
    test_method "beep (600 Hz)" "beep -f 600 -l 200 2>/dev/null"
  else
    echo -e "${YELLOW}⚠️  beep not found (optional)${NC}"
  fi
  
  echo ""
  
  # paplay (PulseAudio)
  if command -v paplay &> /dev/null; then
    # Try to find a sound file
    if [[ -f "/usr/share/sounds/freedesktop/stereo/complete.oga" ]]; then
      test_method "paplay" "paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null"
    else
      echo -e "${YELLOW}⚠️  paplay found but no sound files available${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  paplay not found (install PulseAudio/PipeWire)${NC}"
  fi
  
elif [[ "$PLATFORM" == "Windows" ]]; then
  echo -e "${BLUE}🪟 Testing Windows methods${NC}"
  
  if command -v powershell &> /dev/null; then
    test_method "PowerShell beep" "powershell -c \"[console]::beep(1000,150)\""
  else
    echo -e "${YELLOW}⚠️  PowerShell not found${NC}"
  fi
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Audio testing complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "If you heard sounds, your system is ready for oc-notify!"
echo ""
