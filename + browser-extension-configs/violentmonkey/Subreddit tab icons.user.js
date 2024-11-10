// ==UserScript==
// @name         Subreddit tab icons
// @description  Replaces tab icons (favicons) on reddit with icons of subreddits.
// @version      6
// @license      MIT
// @author       Andrei Rybak
// @match        https://www.reddit.com/*
// @match        https://new.reddit.com/*
// @match        https://old.reddit.com/*
// @exclude      https://www.reddit.com/account/*
// @exclude      https://new.reddit.com/account/*
// @icon         https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png
// @namespace    https://github.com/rybak
// @homepageURL  https://github.com/rybak/subreddit-tab-icons
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

/* jshint esversion: 6 */

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
	function info(...toLog) {
		console.info(LOG_PREFIX, ...toLog);
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
	const DEFAULT_REDDIT_ICON = 'https://www.redditstatic.com/desktop2x/img/favicon/favicon-96x96.png';

	let srDataUrl = '';
	let srName = '';

	function getSrName() {
		const srNameRegex = /https:[/][/](www|old|new)[.]reddit[.]com[/]r[/](\w+)/g;
		log('Getting subreddit name from', document.location.href);
		const match = srNameRegex.exec(document.location.href);
		if (!match || !match[0]) {
			warn(`Cannot find subreddit URL in "${document.location.href}".`);
			return '';
		}
		return match[2];
	}

	function resetToDefaultIcon() {
		/*
		 * Here we either on a special subreddit as a new page load,
		 * or as a load-less switch in New Reddit.  In latter case,
		 * we need to reset the icon from whatever previous subreddit
		 * might have been loaded.
		 */
		setFavicon(DEFAULT_REDDIT_ICON, () => {
			log(`Cannot reset the icon for "${document.location.href}". Aborting.`);
		});
	}

	function replaceOnNewPage() {
		log('Replacing on new page', document.location.href);
		const srNameRegex = /https:[/][/](www|old|new)[.]reddit[.]com[/]r[/](\w+)/g;
		const match = srNameRegex.exec(document.location.href);
		if (!match || !match[0]) {
			warn(`Cannot find subreddit URL in "${document.location.href}". Resetting the icon to the default.`);
			resetToDefaultIcon();
			return;
		}
		srName = match[2];
		if (SPECIAL_NAMES.includes(srName)) {
			log(`Detected special subreddit "${srName}". Resetting the icon to the default.`);
			resetToDefaultIcon();
			return;
		}
		const srUrl = match[0];
		srDataUrl = `${srUrl}/about.json`;
		replaceFavicon();
	}

	function tryAgain(errorFn) {
		log(`Trying again after ${delayMs} ms...`);
		setTimeout(errorFn, delayMs);
		delayMs = delayMs * 2;
	}

	function setFavicon(url, errorFn) {
		const selector = 'link[rel="icon"], link[rel="icon shortcut"], link[rel="apple-touch-icon"]';
		const faviconNodes = document.querySelectorAll(selector);
		if (!faviconNodes || faviconNodes.length == 0) {
			error('Cannot find favicon elements. Selector =', selector);
			info('All link tags for the bug report:');
			document.querySelectorAll('link').forEach(t => {
				info(t);
			});
			tryAgain(errorFn);
			return;
		}
		log('Using new URL =', url);
		faviconNodes.forEach(node => {
			log('Replacing old URL =', node.href);
			node.href = url;
		});
		log('Done.');
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
				if (DEBUG_ENABLED) {
					debug('Options for', document.location.href, options);
				}
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
				warn(`It seems that subreddit "${srName}" doesn't have its own icons defined. Resetting the icon to the default.`);
				resetToDefaultIcon();
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

	replaceOnNewPage();

	/*
	 * Clicking on a link on New Reddit doesn't trigger a page load (sometimes,
	 * at least).  To cover such cases, we need to automatically detect that
	 * the subreddit in the URL has changed.
	 *
	 * For whatever reason (either limitations of userscripts, or trickery of
	 * New Reddit, or both), listener for popstate events doesn't work to
	 * detect a change in the URL.
	 * https://developer.mozilla.org/en-US/docs/Web/API/Window/popstate_event
	 *
	 * As a workaround, observe the changes in the <title> tag, since most
	 * subreddits will have different <title>s.
	 */
	const observer = new MutationObserver((mutationsList) => {
		const maybeNewSrName = getSrName();
		log('Mutation to', maybeNewSrName);
		if (maybeNewSrName != srName) {
			log('MutationObserver: subreddit has changed:', document.location.href);
			replaceOnNewPage();
		}
	});
	observer.observe(document.querySelector('title'), { subtree: true, characterData: true, childList: true });
	log('Added MutationObserver');
})();
