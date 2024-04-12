#!/usr/bin/env osascript -l JavaScript

function run(argv) {
  ObjC.import('stdlib');
  const time = $.getenv('duration_input');

  const ACCEPTED_UNITS_SECONDS = ['s', 'sec', 'secs', 'second', 'seconds'];
  const ACCEPTED_UNITS_MINUTES = ['', 'm', 'min', 'mins', 'minute', 'minutes'];
  const ACCEPTED_UNITS_HOURS = ['h', 'hr', 'hrs', 'hour', 'hours'];

  const inputToTimeMap = (input) => {
    const times = [...(input || '').trim().matchAll(/(\d*\.?\d+)\s*(\w*)/ig)];
  
    return times.reduce((res, [_, digits, units]) => {
      const number = Number(digits);
      if (ACCEPTED_UNITS_SECONDS.includes(units)) {
        res.seconds = number > 0 && number;
      }
      if (ACCEPTED_UNITS_MINUTES.includes(units)) {
        res.minutes = number > 0 && number;
      }
      if (ACCEPTED_UNITS_HOURS.includes(units)) {
        res.hours = number > 0 && number;
      }
      
      return res;
    }, {});
  };

  const timeMapToSeconds = (timeMap) => {
    return Object.entries(timeMap).reduce((seconds, [unit, amount]) => {
      switch (unit) {
        case 'hours':
          seconds += amount * 60 * 60;
          break;
        case 'minutes':
          seconds += amount * 60;
          break;
        case 'seconds':
          seconds += amount;
          break;
        default:
          break;
      }

      return seconds;
    }, 0);
  };

  return timeMapToSeconds(inputToTimeMap(time));
}