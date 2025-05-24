#!/usr/bin/env zsh

backup_path="$HOME/.config/.bootstrap/plist/"

plists=(
	# macOS
	com.apple.Preferences
	com.apple.screensaver
	com.apple.dock
	com.apple.finder
	com.apple.iCal                                      # Calendar.app
	com.apple.notificationcenterui                      # notification center & widgets
	com.apple.preference.gene com.apple.symbolichotkeys # system shortcuts
	com.apple.remindd                                   # Reminders.app
	com.apple.symbolichotkeys                           # system shortcuts

	# printer
	Printer.RICOH-Printer
	com.apple.print.custompresets.forprinter.RICOH_SP_150
	com.apple.print.custompresets
	org.cups.PrintingPrefs

	# apps
	com.Replacicon.Replacicon
	com.colliderli.iina
	com.lwouis.alt-tab-macos
	com.runningwithcrayons.Alfred-Preferences
	com.runningwithcrayons.Alfred
	com.tinyspeck.slackmacgap
	mr.pennyworth.AlfredExtraPane
	net.ankiweb.dtop
	net.freemacsoft.AppCleaner
	org.giorgiocalderolla.Catch
	org.m0k.transmission
	us.zoom.xos
	org.sbarex.SourceCodeSyntaxHighlight.plist
)

#───────────────────────────────────────────────────────────────────────────────

for name in "${plists[@]}"; do
	defaults export "$name" "$backup_path/$name.plist"
done

killall NotificationCenter
killall Dock
killall Finder
