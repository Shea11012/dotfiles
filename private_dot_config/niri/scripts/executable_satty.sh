#!/usr/bin/env bash

niri msg action screenshot
sleep 0.5
wl-paste -t image/png | satty -f -
