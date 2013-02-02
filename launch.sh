#!/bin/bash

./led_controller.pl &
node ./webblinker.js

wait

