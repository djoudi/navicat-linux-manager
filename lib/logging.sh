#!/usr/bin/env bash
write_log() { printf '[navicat-manager] %s\n' "${1:-Operation completed}" >&2; }
