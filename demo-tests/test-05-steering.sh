#!/usr/bin/env bash
# Test 5: Steering & Interruption
# Demonstrates GetSteeringMessages hook for human-in-the-loop

set -e

echo "=== Test 5: Steering & Interruption ==="
echo
echo "This test validates the steering/interruption feature from Phase H."
echo
echo "Steering Features Demonstrated:"
echo "  - GetSteeringMessages hook interrupts mid-execution"
echo "  - Remaining tools skipped (3 of 4 file creations prevented)"
echo "  - Steering message injected into conversation"
echo "  - Model understands and complies with interruption"
echo
echo "Implementation: See projects/bommalata/cmd/demo-steering/main.go"
echo "Documentation: See demo-results/test-05-steering.md"
echo
echo "Execution:"
cd /var/lib/smriti/workspace/projects/bommalata
export $(grep OPENROUTER_API_KEY local/secrets.env | xargs)
CGO_ENABLED=1 nix develop -c go run ./cmd/demo-steering
echo
echo "=== Test 5 Complete ✅ ==="
