// ==UserScript==
// @name        Discord: Redirect to Discord app
// @namespace   Violentmonkey Scripts
// @match       https://discord.com/channels/*
// @match       http://discord.com/channels/*
// @version     1.1
// @author      pseudometa
// @icon        https://logodownload.org/wp-content/uploads/2017/11/discord-logo-1-1.png
// ==/UserScript==

// INFO needs "always open link with Discord" to be confirmed once
window.location.href = window.location.href.replace(/https?:/, "discord://");

// close leftover tab. Delayed, to prevent race condition with link-opening
setTimeout(() => window.close(), 1000)
