#!/usr/bin/env bash
case $SSH_ORIGINAL_COMMAND in
  'manager.sh'*)
    exec $SSH_ORIGINAL_COMMAND
    ;;
  'scp'*)
    exec $SSH_ORIGINAL_COMMAND
    ;;
  'mktemp'*)
    exec $SSH_ORIGINAL_COMMAND
    ;;
  'rm'*)
    exec $SSH_ORIGINAL_COMMAND
    ;;
  *)
    echo "Access Denied"
    ;;
esac


