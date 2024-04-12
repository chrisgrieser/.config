#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  ObjC.import('stdlib');
  const timers = JSON.parse($.getenv('timers_list'));
  const id = String(argv[0]);

  delete timers[id];

  return JSON.stringify(timers, null, 2);
}