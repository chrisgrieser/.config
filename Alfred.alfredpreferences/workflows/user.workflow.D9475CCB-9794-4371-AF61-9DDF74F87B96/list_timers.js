#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  ObjC.import('stdlib');
  const timers = JSON.parse($.getenv('timers_list'));

  const calculateFireTime = (seconds) => {
    const options = {
      hour: 'numeric',
      minute: 'numeric',
      second: 'numeric',
      hour12: false,
    };

    return new Intl.DateTimeFormat('en-US', options).format(seconds);
  };

  const items = Object.keys(timers)
    .sort((timerA, timerB) => Number(timerA) - Number(timerB))
    .map((id) => {
      const message = timers[id].message;
      const isPomodoro = timers[id].isPomodoro;

      return {
        title: calculateFireTime(id),
        subtitle: message,
        arg: id,
        icon: {
          path: isPomodoro ? './list_pomodoro.png' : './list_timer.png',
        },
        variables: {
          'selected_timer_id': id,
          'timer_message': message,
          'timer_is_pomodoro': isPomodoro,
        },
      };
    });

  items.push({
    title: items.length === 0 ? 'No active timers. Create new one?' : 'Create new',
    arg: 'new',
    icon: {
      path: './add.png',
    },
  });

  return JSON.stringify({
    items,
  });
}