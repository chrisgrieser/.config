// ==UserScript==
// @name         Reddit Syntax Highlighting
// @namespace    pseudometa
// @version      1.0
// @description  Reddit code block syntax highlighting with highlight.js. CAVEAT: Requires reddit users to add a language tag to the fenced code block, which apparently many people do not do…
// @author       pseudometa
// @icon         https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png
// @match        https://www.reddit.com/r/*
// @match        https://new.reddit.com/r/*
// @match        https://old.reddit.com/r/*
// @resource     css   https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css
// @require      https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js
// @grant        GM_addStyle
// @grant        GM_getResourceText
// ==/UserScript==


// INFO: This userscript is based on
// https://www.reddit.com/r/reddithax/comments/3ehlg7/code_syntax_highlighting_with_highlightjs_and_a/
// https://greasyfork.org/en/scripts/412865-atcoder-better-highlighter

// change the @resource and @require URLs to modify highlight.js version or syntax highlighting theme
// get URLs from: https://cdnjs.com/libraries/highlight.js

GM_addStyle(GM_getResourceText("css"));
(function (){
    hljs.initHighlighting();
 })()