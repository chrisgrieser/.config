// ==UserScript==
// @name         Wikiwand
// @version      1.1.0
// @description  Wikiwand browser extension replacement
// @author       kidonng
// @namespace    https://github.com/kidonng/cherry
// @run-at       document-start
// @match        https://*.wikipedia.org/*
// @match        https://www.wikiwand.com/*
// ==/UserScript==

;(() => {
  const { hostname, pathname, search, hash } = location

  if (hostname === 'www.wikiwand.com') {
    return (document.onreadystatechange = () => {
      if (document.readyState === 'complete')
        document
          .querySelector(decodeURIComponent(hash.replace('/', '')))
          .scrollIntoView()
    })
  }

  const params = new URLSearchParams(search)
  if (
    params.has('action') ||
    params.has('oldid') ||
    params.get('oldformat') === 'true'
  )
    return

  // 1. /wiki/title
  // 2. /w/index.php?title=title&variant=lang
  // 3. /lang/title
  const [, type, _title] = pathname.split('/')
  const lang =
    type === 'wiki'
      ? hostname.split('.')[0]
      : type === 'w'
      ? params.get('variant')
      : type
  const title = type === 'w' ? params.get('title') : _title

  if (
    title.startsWith('Special:') ||
    title.startsWith('User:') ||
    title.startsWith('User_talk:')
  )
    return

  location.href = `https://www.wikiwand.com/${lang}/${title}${
    hash ? hash.replace('cite_note-', 'citenote') : ''
  }`
})()
