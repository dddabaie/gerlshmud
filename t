#!/usr/bin/env bash
rm -rf logs/*
CT_OPTS="-config test/test.config" ERLMUD_LOG_PATH=$(pwd)/logs make ct | tee  out
cp log_wrappers/*.{js,css} logs/
cat log_wrappers/log_head logs/log.html log_wrappers/log_tail > logs/erlmud_log.html
