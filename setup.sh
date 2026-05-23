#!/bin/bash
# Run this script from the root of your target repo to configure VS Code workspace
# settings.

set -e

PACK_DIR=".github/harness_coding_instructions"
VSCODE_DIR=".vscode"
SETTINGS_FILE="$VSCODE_DIR/settings.json"

if [ ! -d "$PACK_DIR" ]; then
    echo "Error: $PACK_DIR not found." >&2
    echo "Run this script from the target repo root after copying the pack to $PACK_DIR/." >&2
    exit 1
fi

REQUIRED_PACK_PATHS=(
    "copilot-instructions.md"
    "workflow/vscode_workflow"
    "workflow/vscode_token_effective_workflow"
    "workflow/codex_token_effective_workflow"
    "request_template"
    "philosophy/philosophy.instructions.md"
    "_lib/safety_rules.md"
    "_lib/workflow_contract.md"
)

for required_path in "${REQUIRED_PACK_PATHS[@]}"; do
    if [ ! -e "$PACK_DIR/$required_path" ]; then
        echo "Error: $PACK_DIR exists but is missing $required_path." >&2
        echo "Copy the full harness_coding_instructions pack before running setup." >&2
        exit 1
    fi
done

# ---------------------------------------------------------------------------
# 1. Add chat.instructionsFilesLocations to .vscode/settings.json
# ---------------------------------------------------------------------------
mkdir -p "$VSCODE_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "chat.instructionsFilesLocations": {
    ".github/harness_coding_instructions": true,
    ".claude/rules": true
  },
  "chat.agentFilesLocations": {
    ".github/harness_coding_instructions/agents": true
  },
  "chat.includeReferencedInstructions": true
}
EOF
    echo "Created $SETTINGS_FILE"
else
    # Try Python3 first, fall back to Node.js, then to manual instructions
    if command -v python3 >/dev/null 2>&1; then
        python3 - << 'PYEOF'
import json
import re

path = ".vscode/settings.json"
with open(path, "r") as f:
    raw = f.read()

def strip_jsonc(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"(^|[^:])//.*", r"\1", text, flags=re.M)
    text = re.sub(r",(\s*[}\]])", r"\1", text)
    return text

settings = json.loads(strip_jsonc(raw))

locations = settings.get("chat.instructionsFilesLocations")
if not isinstance(locations, dict):
    locations = {}

locations.pop(".github/agentic_coding_instructions", None)
locations[".github/harness_coding_instructions"] = True
locations[".claude/rules"] = True
settings["chat.instructionsFilesLocations"] = locations

agent_locations = settings.get("chat.agentFilesLocations")
if not isinstance(agent_locations, dict):
    agent_locations = {}
agent_locations[".github/harness_coding_instructions/agents"] = True
settings["chat.agentFilesLocations"] = agent_locations

settings["chat.includeReferencedInstructions"] = True

with open(path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("Updated .vscode/settings.json")
PYEOF
    elif command -v node >/dev/null 2>&1; then
        node -e "
const fs = require('fs');
const path = '.vscode/settings.json';
const settings = JSON.parse(fs.readFileSync(path, 'utf8'));
if (!settings['chat.instructionsFilesLocations'] || typeof settings['chat.instructionsFilesLocations'] !== 'object') {
    settings['chat.instructionsFilesLocations'] = {};
}
delete settings['chat.instructionsFilesLocations']['.github/agentic_coding_instructions'];
settings['chat.instructionsFilesLocations']['.github/harness_coding_instructions'] = true;
settings['chat.instructionsFilesLocations']['.claude/rules'] = true;
if (!settings['chat.agentFilesLocations'] || typeof settings['chat.agentFilesLocations'] !== 'object') {
    settings['chat.agentFilesLocations'] = {};
}
settings['chat.agentFilesLocations']['.github/harness_coding_instructions/agents'] = true;
settings['chat.includeReferencedInstructions'] = true;
fs.writeFileSync(path, JSON.stringify(settings, null, 2) + '\n');
console.log('Updated .vscode/settings.json');
"
    elif command -v jq >/dev/null 2>&1; then
        tmp=$(mktemp)
        jq '.["chat.instructionsFilesLocations"] = ((.["chat.instructionsFilesLocations"] // {}) | del(.[".github/agentic_coding_instructions"]) | .[".github/harness_coding_instructions"] = true | .[".claude/rules"] = true) | .["chat.agentFilesLocations"] = ((.["chat.agentFilesLocations"] // {}) | .[".github/harness_coding_instructions/agents"] = true) | .["chat.includeReferencedInstructions"] = true' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
        echo "Updated .vscode/settings.json"
    else
        echo "WARNING: python3, node, and jq not found."
        echo "Please manually add this to $SETTINGS_FILE:"
        echo '  "chat.instructionsFilesLocations": {'
        echo '    ".github/harness_coding_instructions": true,'
        echo '    ".claude/rules": true'
        echo '  },'
        echo '  "chat.agentFilesLocations": {'
        echo '    ".github/harness_coding_instructions/agents": true'
        echo '  },'
        echo '  "chat.includeReferencedInstructions": true'
    fi
fi

# ---------------------------------------------------------------------------
# 2. Safe-copy copilot-instructions.md to .github/copilot-instructions.md
# ---------------------------------------------------------------------------
COPILOT_SRC="$PACK_DIR/copilot-instructions.md"
COPILOT_DEST=".github/copilot-instructions.md"

if [ -f "$COPILOT_SRC" ]; then
    mkdir -p ".github"
    if [ ! -f "$COPILOT_DEST" ]; then
        sed 's|#file:|#file:harness_coding_instructions/|g' "$COPILOT_SRC" > "$COPILOT_DEST"
        echo "Created $COPILOT_DEST"
    elif grep -Fq "Master Orchestrator — Instruction Router" "$COPILOT_DEST"; then
        sed 's|#file:|#file:harness_coding_instructions/|g' "$COPILOT_SRC" > "$COPILOT_DEST"
        echo "Refreshed $COPILOT_DEST"
    else
        echo "WARNING: $COPILOT_DEST exists with custom content — leaving unchanged." >&2
    fi
fi

echo "Done."
