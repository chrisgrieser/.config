#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  ObjC.import('stdlib');
  const timers = JSON.parse($.getenv('timers_list'));
  const id = String($.getenv('timer_id'));
  const message = $.getenv('timer_message');

  let isPomodoro = false;

  try {
    isPomodoro = JSON.parse($.getenv('timer_is_pomodoro'));
  } catch {}

  timers[id] = { message, isPomodoro };

  return JSON.stringify(timers, null, 2);
}