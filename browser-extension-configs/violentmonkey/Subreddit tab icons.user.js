// ==UserScript==
// @name         Subreddit tab icons
// @description  Replaces tab icons (favicons) on reddit with icons of subreddits.
// @version      1.2
// @license      MIT
// @author       Andrei Rybak
// @match        https://www.reddit.com/r/*
// @match        https://new.reddit.com/r/*
// @match        https://old.reddit.com/r/*
// @icon         https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png
// @namespace    https://github.com/rybak
// @grant        none
// ==/UserScript==

/*
 * Copyright (c) 2023 Andrei Rybak
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

(function() {
    'use strict';

    const LOG_PREFIX = '[reddit tab icons]';
    const DEBUG_ENABLED = false;
    function error(...toLog) {
        console.error(LOG_PREFIX, ...toLog);
    }
    function warn(...toLog) {
        console.warn(LOG_PREFIX, ...toLog);
    }
    function log(...toLog) {
        console.log(LOG_PREFIX, ...toLog);
    }
    function debug(...toLog) {
        console.debug(LOG_PREFIX, ...toLog);
    }

    /*
     * Delay to wait after an error until next attempt, in milliseconds.
     * Doubles after every error.
     */
    var delayMs = 1000;
    const SPECIAL_NAMES = ['all', 'friends', 'popular'];

    const srNameRegex = /https:[/][/](www|old|new)[.]reddit[.]com[/]r[/](\w+)/g;
    const match = srNameRegex.exec(document.location.href);
    if (!match[0]) {
        error(`Could not find subreddit URL in "${document.location.href}". Aborting.`);
        return;
    }
    const srName = match[2];
    if (SPECIAL_NAMES.includes(srName)) {
        log(`Detected special subreddit "${srName}". Aborting.`);
        return;
    }
    const srUrl = match[0];
    const srDataUrl = `${srUrl}/about.json`;

    function tryAgain(errorFn) {
        log(`Trying again after ${delayMs} ms...`);
        setTimeout(errorFn, delayMs);
        delayMs = delayMs * 2;
    }

    function setFavicon(url, errorFn) {
        const faviconNodes = document.querySelectorAll('link[rel="icon"]');
        if (!faviconNodes || faviconNodes.length == 0) {
            warn("Couldn't find favicon elements.");
            tryAgain(errorFn);
            return;
        }
        log(`Using URL = "${url}". Done.`);
        faviconNodes.forEach(node => {
            node.href = url;
        });
    }

    /*
     * For some reason .community_icon is partially HTML encoded.
     * Seems like a Reddit bug. Work around the bug by HTML decoding
     * the string.
     */
    function cleanUpCommunityIcon(url) {
        if (!url || url.length == 0) {
            return url;
        }
        // https://stackoverflow.com/a/34064434/1083697
        function htmlDecode(input) {
            const doc = new DOMParser().parseFromString(input, "text/html");
            return doc.documentElement.textContent;
        }
        const res = htmlDecode(url);
        log(`Converted community_icon from "${url}" to "${res}".`);
        return res;
    }

    /*
     * I couldn't figure out a simple way to _reliably_ determine
     * if a website on www.reddit.com is Old Reddit or New Reddit.
     * So that's why there is this weird ping-pong error handling.
     */
    function replaceFavicon() {
        /*
         * For old.reddit.com
         */
        function replaceFaviconOld() {
            function useSrData(data) {
                if (DEBUG_ENABLED) {
                    debug('Received JSON:', data);
                }
                /*
                 * Not every subreddit has all these different images
                 * defined in their style/theme/look-and-feel/whatever.
                 * Therefore, try several different options.
                 */
                const communityIcon = cleanUpCommunityIcon(data.community_icon);
                const options = [communityIcon, data.icon_img, data.header_img];
                for (const img of options) {
                    if (img && img.length > 0) {
                        setFavicon(img, replaceFaviconNew);
                        return;
                    }
                }
                /*
                 * If we loaded "about.json" and it come up empty for
                 * all three options of different fields for the icon,
                 * it means that the subreddit likely doesn't have
                 * the icon defined in the settings at all. Abort in
                 * such cases.
                 */
                warn(`It seems that subreddit "${srName}" doesn't have its own icons defined. Aborting.`);
            }
            /*
             * Download data about the subreddit from Reddit API.
             * https://old.reddit.com/r/redditdev/comments/dot8tn/how_can_i_get_the_icon_of_a_subreddit/
             */
            log(`Loading from "${srDataUrl}"...`);
            const srDataPromise = fetch(srDataUrl);
            // https://stackoverflow.com/a/43175774/1083697
            srDataPromise.then(res => res.json())
                .then(json => useSrData(json.data))
                .catch(err => {
                error(`Got error while getting ${srDataUrl}`, err);
                tryAgain(replaceFaviconNew);
            });
        }

        /*
         * For new.reddit.com
         */
        function replaceFaviconNew() {
            const srIcon = document.querySelector('img[alt="Subreddit-Symbol"]');
            if (!srIcon) {
                warn("Couldn't find the icon in HTML of New Reddit.");
                tryAgain(replaceFaviconOld);
                return;
            }
            setFavicon(srIcon.src, replaceFaviconOld);
        }

        /*
         * Users of Old Reddit are more likely to use explicit URL
         * old.reddit.com than users of New Reddit, so check for
         * "old" first.
         */
        if (document.location.hostname.includes('old')) {
            replaceFaviconOld();
        } else {
            /*
             * Here the user is either using www.reddit.com or
             * explicit new.reddit.com. Users of www.reddit.com are
             * more likely to be using New Reddit (i.e. the default),
             * so try it out first.
             */
            replaceFaviconNew();
        }
    }

    replaceFavicon();
})();