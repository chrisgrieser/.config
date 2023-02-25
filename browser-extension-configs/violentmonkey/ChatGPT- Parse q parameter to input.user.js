// ==UserScript==
// @name        ChatGPT: Parse q parameter to input
// @match       https://chat.openai.com/chat*
// @grant       none
// @version     1.0
// @author      strajk.me
// ==/UserScript==

// https://github.com/Strajk/setup/blob/164db9b97ac728c5bba4b543f4cbc6be68f0962e/user-scripts/chatgpt-q-param-to-input.user.js
// https://twitter.com/Straaajk/status/1599540688265220097

const inputSelector = "textarea[data-id='root']"

// setInterval until inputSelector is on the page
const interval = setInterval(() => {
  const inputEl = document.querySelector(inputSelector)
  if (inputEl) {
    clearInterval(interval)
    // Parse the "q" param from the query string
    const urlObj = new URL(window.location.href)
    const q = urlObj.searchParams.get("q")
    if (!q) return

    // Set the input field to the value of the "q" param
    inputEl.value = q

    // Submit the form
    // const form = inputEl.closest("form")
    // form.dispatchEvent(new Event("submit")) // eslint-disable-line no-undef
    const button = inputEl.nextElementSibling
    button.click()
  }
}, 500)