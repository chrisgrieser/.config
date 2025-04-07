#!/usr/bin/env osascript -l JavaScript

// Demonstration of running a JXA script as a command-line executable
// Mitchell L Model, dev@software-concepts.org, 2017-01-22

// Run by typing name of the script and arguments at the command-line.
// (Don't forget to make script executable.)
//

// based on:
//     https://github.com/dtinth/JXA-Cookbook/wiki/Shell-and-CLI-Interactions

// NSProcessInfo:
//     https://developer.apple.com/reference/foundation/nsprocessinfo
// NSProcessInfo.processInfo.arguments:
//     https://developer.apple.com/reference/foundation/
//                             nsprocessinfo/1415596-arguments?language=objc

ObjC.import('stdlib')                               // for exit

const args = $.NSProcessInfo.processInfo.arguments    // NSArray
const argv = []
for (let i = 4; i < args.count; i++) {
    // skip 3-word run command at top and this file's name
    console.log($(args.objectAtIndex(i)).js)       // print each argument
    argv.push(ObjC.unwrap(args.objectAtIndex(i)))  // collect arguments
}
console.log(argv);                                 // print arguments
