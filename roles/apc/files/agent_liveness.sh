#!/bin/sh
if [[ -z "${KUBERNETES_SERVICE_HOST}" ]]; then
  echo "$(date) K8S Environment variables are missing." >> /var/log/agent_liveness.log
  echo "$(printenv)" >> /var/log/agent_liveness.log
  echo "$(date) Restarting Agent..." >> /var/log/agent_liveness.log
  kill $(pidof uc_agent)
  exit 1
else
  exit 0
fi
