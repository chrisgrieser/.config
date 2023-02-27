// ==UserScript==
// @name         Zoom Redirector
// @namespace    Violentmonkey Scripts
// @version      1.0
// @description  Open directly in Zoom App instead of opening a tab
// @author       pseudometa
// @match        *://*.zoom.us/j/*
// ==/UserScript==

/* global document, window */
const url = document.URL.replace(
	/https?:\/\/.*\.zoom\.us\/j\/(\w+)\?pwd=(\w+)$/,
	"zoommtg://zoom.us/join?confno=$1&pwd=$2",
);

window.location.href = url;
