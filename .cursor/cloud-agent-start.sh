#!/usr/bin/env bash
set -euo pipefail

SESSION_NAME="geolibre-dev"
PORT=5173

if curl -sf "http://localhost:${PORT}/" >/dev/null 2>&1; then
  echo "GeoLibre dev server already running on port ${PORT}"
  exit 0
fi

if tmux -f /exec-daemon/tmux.portal.conf has-session -t "=${SESSION_NAME}" 2>/dev/null; then
  tmux -f /exec-daemon/tmux.portal.conf kill-session -t "${SESSION_NAME}"
fi

tmux -f /exec-daemon/tmux.portal.conf new-session -d -s "${SESSION_NAME}" -c /workspace -- "${SHELL:-bash}" -l -c "npm run dev"

for _ in $(seq 1 60); do
  if curl -sf "http://localhost:${PORT}/" >/dev/null 2>&1; then
    echo "GeoLibre dev server ready at http://localhost:${PORT}/ (network: http://0.0.0.0:${PORT}/)"
    exit 0
  fi
  sleep 2
done

echo "GeoLibre dev server failed to become ready on port ${PORT}" >&2
exit 1
