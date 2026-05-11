#!/usr/bin/env bash

set -euo pipefail

ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}
RMF_WEB_API_IMAGE=${RMF_WEB_API_IMAGE:-ghcr.io/open-rmf/rmf-web/api-server:jazzy-nightly}
RMF_WEB_API_STATE_DIR=${RMF_WEB_API_STATE_DIR:-/tmp/rmf_web_api_run}

mkdir -p "${RMF_WEB_API_STATE_DIR}/log"

exec docker run \
  --rm -it \
  --network host \
  --ipc host \
  --user "$(id -u):$(id -g)" \
  -e ROS_DOMAIN_ID="${ROS_DOMAIN_ID}" \
  -e RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION}" \
  -e ROS_LOG_DIR=/ws/run/log \
  -v "${RMF_WEB_API_STATE_DIR}:/ws/run" \
  "${RMF_WEB_API_IMAGE}"