#!/bin/zsh
CRON_JOB_FOLDER="$DOTFILE_FOLDER/Cron Jobs"

echo -n "" | crontab - # to reset
function add-cronjob () {
	(crontab -l && echo "$1 \"$CRON_JOB_FOLDER/$2\"") | crontab -
}

add-cronjob "*/15 * * * *" '15-min_[Browser-Path].sh'
add-cronjob "5 3 * * *" 'sleep-timer_[Browser].applescript'
add-cronjob "5 6 * * *" 'daily-morning_[Browser].applescript'
add-cronjob "5 21 * * *" 'daily-evening.applescript'
add-cronjob "10 6 * * 0,3" 'biweekly.applescript'

echo ""
crontab -l # check the current cronjobs

# prevent mail alerts https://www.cyberciti.biz/faq/disable-the-mail-alert-by-crontab-command/
# if line below is disabled, a log of cronjobs can be accesssed via `mail`
# mails can be deleted by removing `/private/var/mail/chrisgrieser`
(crontab -l && echo "MAILTO=''") | crontab -

#-------------------------------------------------------------------------------

# wake before morning cronjobs run → https://www.dssw.co.uk/reference/pmset.html
sudo pmset repeat wake MTWRFSU 06:01:00
