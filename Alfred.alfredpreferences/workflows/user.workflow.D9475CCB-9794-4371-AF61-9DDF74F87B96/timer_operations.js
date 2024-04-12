#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  const items = [
  {
    title: 'Set new time',
    arg: 'new_time',
    icon: {
      path: './edit_time.png',
    },
  },
  // {
  //   title: 'Edit message',
  //   arg: 'edit_message',
  // },
  {
    title: 'Cancel timer',
    arg: 'cancel',
    icon: {
      path: './cancel.png',
    },
  }];

  return JSON.stringify({
	skipknowledge: true,
    items,
  });
}