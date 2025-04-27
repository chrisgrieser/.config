#!/usr/bin/env zsh

function backup_plist {
	local backup_path="$HOME/.config/.bootstrap/plist" # CONFIG
	local plist="$1"
	defaults export "$plist" "$backup_path/$plist.plist"
}

#───────────────────────────────────────────────────────────────────────────────

backup_plist com.apple.notificationcenterui # notification center & widgets
backup_plist com.apple.iCal.plist # Calendar.app
backup_plist com.lwouis.alt-tab-macos.plist # AltTab
backup_plist com.apple.symbolichotkeys.plist # system shortcuts
backup_plist com.apple.preference.general.plist
backup_plist com.apple.Preferences.plist
backup_plist mr.pennyworth.AlfredExtraPane.plist
backup_plist com.colliderli.iina.plist
backup_plist com.runningwithcrayons.Alfred-Preferences.plist
backup_plist org.m0k.transmission.plist
backup_plist org.giorgiocalderolla.Catch.plist
backup_plist net.freemacsoft.AppCleaner.plist
backup_plist com.apple.finder.plist
