#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  ObjC.import('stdlib');
  const seconds = $.getenv('timer_seconds');

  const message = argv[0] || 'Beep-beep, timer went off!';

  const calculateFireTime = (seconds) => {
    const options = {
      hour: 'numeric',
      minute: 'numeric',
      second: 'numeric',
      hour12: false,
    };

    const showTime = Date.now() + seconds * 1000;

    return new Intl.DateTimeFormat('en-US', options).format(showTime);
  };

  const items = [{
    title: 'Set timer message',
    subtitle: `Will fire at ${calculateFireTime(seconds)}`,
    arg: message,
    variables: {
      'timer_message': message,
    },
  }];

  return JSON.stringify({
    rerun: 1,
    items,
  });
}
