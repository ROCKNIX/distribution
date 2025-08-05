#!/bin/bash
echo "=== Prompt Version Comparison ==="
echo "Comparing versions between .github/shared-copilot-knowledge/prompts/ (new) and .github/prompts/ (current)"
echo

for file in .github/shared-copilot-knowledge/prompts/*.prompt.md; do
  if [[ -f "$file" ]]; then
    filename=$(basename "$file")
    shared_version=$(grep "^version:" "$file" | cut -d'"' -f2 2>/dev/null || echo "unknown")
    
    if [[ -f ".github/prompts/$filename" ]]; then
      current_version=$(grep "^version:" ".github/prompts/$filename" | cut -d'"' -f2 2>/dev/null || echo "unknown")
      echo "📄 $filename:"
      echo "   Current: $current_version → Available: $shared_version"
      
      if [[ "$shared_version" != "$current_version" ]]; then
        echo "   ⚠️  Version change detected!"
      fi
    else
      echo "📄 $filename:"
      echo "   🆕 New file (version: $shared_version)"
    fi
    echo
  fi
done

echo "To deploy new versions manually:"
echo "   cp .github/shared-copilot-knowledge/prompts/*.prompt.md .github/prompts/"
echo
echo "To compare specific files:"
echo "   diff .github/prompts/[filename] .github/shared-copilot-knowledge/prompts/[filename]"
