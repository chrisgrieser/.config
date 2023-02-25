// ==UserScript==
// @name         YouTube Skip Redirector
// @namespace   Violentmonkey Scripts
// @match        *://www.youtube.com/redirect?*
// @grant       none
// @version     1.0
// @author      pseudometa
// @description  Skip YouTube Redirection Information Page
// ==/UserScript==


const theURL = document.URL
    .replace(/.*youtube\.com.*&q=/gi, "");
const decodedURL = decodeURIComponent(theURL);
// INFO since the URL needs to be decoded, this cannot be done with a simple redirector extension

window.location.href = (decodedURL);