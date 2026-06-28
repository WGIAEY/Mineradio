# Mineradio Makefile
# Cross-platform build orchestration for macOS and Windows

APP_NAME    := Mineradio
VERSION     := $(shell node -p "require('./package.json').version" 2>/dev/null || echo "0.0.0")
DIST_DIR    := dist
BUILD_DIR   := build
NODE_MODS   := node_modules
ELECTRON    := $(NODE_MODS)/electron/dist/Electron.app

# ── Platform detection ───────────────────────────────────────────
UNAME_S     := $(shell uname -s 2>/dev/null || echo Windows)
IS_MAC      := $(shell [ "$(UNAME_S)" = "Darwin" ] && echo 1 || echo 0)
IS_LINUX    := $(shell [ "$(UNAME_S)" = "Linux"  ] && echo 1 || echo 0)
IS_WIN_SH   := $(shell echo "$(UNAME_S)" | grep -qE 'MINGW|CYGWIN|MSYS' && echo 1 || echo 0)
IS_WIN      := $(shell echo "$(OS)" | grep -qi windows && echo 1 || echo 0)

# ── Colors ────────────────────────────────────────────────────────
C_RESET  := \033[0m
C_BOLD   := \033[1m
C_GREEN  := \033[32m
C_CYAN   := \033[36m
C_YELLOW := \033[33m

# ── Default target ────────────────────────────────────────────────
.PHONY: help
help: ## Show available targets
	@echo "$(C_BOLD)Mineradio $(VERSION)$(C_RESET) — Cross-platform build system"
	@echo ""
	@echo "$(C_CYAN)Development:$(C_RESET)"
	@echo "  make start          Start Electron dev mode (auto-installs deps)"
	@echo "  make install        Install dependencies (npm)"
	@echo ""
	@echo "$(C_CYAN)Build (auto-detects platform):$(C_RESET)"
	@echo "  make build          Build installer for current platform"
	@echo "  make build-mac      Build macOS DMG + ZIP    (requires macOS)"
	@echo "  make build-win      Build Windows NSIS       (best on Windows)"
	@echo "  make build-all      Build all platform targets possible"
	@echo "  make dir            Quick unpackaged build for current platform"
	@echo ""
	@echo "$(C_CYAN)Utilities:$(C_RESET)"
	@echo "  make clean          Remove build artifacts"
	@echo "  make clean-all      Deep clean: dist + node_modules"
	@echo "  make info           Show detected platform & versions"
	@echo ""

# ── Development ───────────────────────────────────────────────────
.PHONY: install start

install: $(NODE_MODS) ## Install dependencies (auto-triggered)

$(NODE_MODS): package.json package-lock.json
	@echo "$(C_CYAN)› Installing dependencies with npm...$(C_RESET)"
	@npm install
	@echo "$(C_GREEN)✓ Dependencies ready$(C_RESET)"

start: install ## Launch Electron dev mode
	@echo "$(C_CYAN)› Starting Mineradio dev mode...$(C_RESET)"
	@npm start

# ── Build: current platform ───────────────────────────────────────
.PHONY: build build-mac build-win build-dir

build: ## Build installer for the current platform
ifeq ($(IS_MAC),1)
	@$(MAKE) build-mac
else
	@$(MAKE) build-win
endif

build-mac: install ## Build macOS DMG + ZIP (macOS only)
ifeq ($(IS_MAC),1)
	@echo "$(C_CYAN)› Building macOS installer (v$(VERSION))...$(C_RESET)"
	@npm run build:mac
	@node build/rename-mac-artifacts.js
	@echo "$(C_GREEN)✓ macOS build complete → $(DIST_DIR)/$(C_RESET)"
	@ls -lh $(DIST_DIR)/Mineradio-*-apple.{dmg,zip} $(DIST_DIR)/Mineradio-*-intel.{dmg,zip} 2>/dev/null || true
else
	@echo "$(C_YELLOW)⚠ macOS builds require macOS. Use 'make build-win' instead.$(C_RESET)"
	@exit 1
endif

build-win: install ## Build Windows NSIS installer
ifeq ($(IS_MAC),1)
	@echo "$(C_CYAN)› Building Windows installer from macOS (cross)...$(C_RESET)"
	@npm run build:win
	@echo "$(C_GREEN)✓ Windows build complete → $(DIST_DIR)/$(C_RESET)"
	@ls -lh $(DIST_DIR)/Mineradio-*-Setup.exe 2>/dev/null || true
else
	@echo "$(C_CYAN)› Building Windows installer...$(C_RESET)"
	@npm run build:win
	@echo "$(C_GREEN)✓ Windows build complete → $(DIST_DIR)/$(C_RESET)"
	@dir $(DIST_DIR)\Mineradio-*-Setup.exe 2>nul || ls $(DIST_DIR)/Mineradio-*-Setup.exe 2>/dev/null || true
endif

build-all: install ## Build for all possible platforms from current host
ifeq ($(IS_MAC),1)
	@echo "$(C_BOLD)Building all targets from macOS...$(C_RESET)"
	@$(MAKE) build-mac
	@$(MAKE) build-win
	@echo "$(C_GREEN)✓ All platform builds complete → $(DIST_DIR)/$(C_RESET)"
	@ls -lh $(DIST_DIR)/ 2>/dev/null || true
else
	@echo "$(C_BOLD)Building all targets from Windows...$(C_RESET)"
	@$(MAKE) build-win
	@echo "$(C_YELLOW)⚠ macOS builds can only be produced on macOS.$(C_RESET)"
	@echo "$(C_GREEN)✓ Windows build complete → $(DIST_DIR)/$(C_RESET)"
endif

dir: install ## Quick unpackaged build for current platform (dir only, faster)
ifeq ($(IS_MAC),1)
	@echo "$(C_CYAN)› Building macOS .app bundle (unpackaged)...$(C_RESET)"
	@npm run build:mac:dir
	@node build/rename-mac-artifacts.js
	@echo "$(C_GREEN)✓ macOS .app ready → $(DIST_DIR)/$(C_RESET)"
else
	@echo "$(C_CYAN)› Building Windows dir (unpackaged)...$(C_RESET)"
	@npm run build:win:dir
	@echo "$(C_GREEN)✓ Windows dir ready → $(DIST_DIR)/$(C_RESET)"
endif

# ── Clean ─────────────────────────────────────────────────────────
.PHONY: clean clean-all

clean: ## Remove build artifacts (dist/)
	@echo "$(C_CYAN)› Cleaning dist/...$(C_RESET)"
	@rm -rf $(DIST_DIR)
	@echo "$(C_GREEN)✓ Clean$(C_RESET)"

clean-all: clean ## Deep clean: dist/ + node_modules/
	@echo "$(C_CYAN)› Removing node_modules/...$(C_RESET)"
	@rm -rf $(NODE_MODS)
	@echo "$(C_GREEN)✓ Deep clean complete$(C_RESET)"

# ── Info ──────────────────────────────────────────────────────────
.PHONY: info
info: ## Show platform and version information
	@echo "$(C_BOLD)Mineradio $(VERSION) — Build Environment$(C_RESET)"
	@echo "  Platform    : $(UNAME_S)"
	@echo "  macOS       : $(IS_MAC)"
	@echo "  Linux       : $(IS_LINUX)"
	@echo "  Node        : $(shell node -v 2>/dev/null || echo 'not found')"
	@echo "  npm         : $(shell npm -v 2>/dev/null || echo 'not found')"
	@echo "  Electron    : $(shell node -p "require('electron/package.json').version" 2>/dev/null || echo 'not installed')"
	@echo "  electron-builder: $(shell node -p "require('electron-builder/package.json').version" 2>/dev/null || echo 'not installed')"
