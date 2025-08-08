#!/usr/bin/osascript -l JavaScript

const frontmostAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0]
const frontmostApp = Application(frontmostAppName)

const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"]
const webkitVariants = ["Safari", "Webkit", "Orion"]

if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
  var currentTabTitle = frontmostApp.windows[0].activeTab.name()
  var currentTabURL = frontmostApp.windows[0].activeTab.url()
} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
  var currentTabTitle = frontmostApp.windows[0].currentTab.name()
  var currentTabURL = frontmostApp.windows[0].currentTab.url()
} else {
  throw new Error("You need a supported browser as your frontmost app")
}

currentTabURL + "\n" + currentTabTitle
