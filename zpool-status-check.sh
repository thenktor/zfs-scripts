#!/bin/sh
# checks zpools for healthiness

EMAIL=root
ZPOOL_STATUS=""
MAIL_SENT="/tmp/zpool-status-check-mail.lock"
DAY_OF_WEEK=7
TIME=0005
CURRENT_TIME=$(date +%H%M)

# help
fnUsage() {
	echo "USAGE: $(basename $0) [options]" 1>&2;
	echo "  -d <day>  : day of week when to send a healthy message, default=7 (sunday). Set to 0 to disable." 1>&2;
	echo "  -h        : show this help message" 1>&2;
	echo "  -m <email>: send notification to this email address, default=root" 1>&2;
	echo "  -t <time> : delete send lock file if started before this time, formatted as hhmm, default=0005" 1>&2;
	exit 1;
}

# arguments
while getopts "d:hm:t:" OPT; do
	case $OPT in
		#c)
			# use healthchecks.io instead of email
			#;;
		d)
			DAY_OF_WEEK="$OPTARG"
			;;
		m)
			EMAIL="$OPTARG"
			;;
		t)
			TIME="$OPTARG"
			;;
		h|*)
			fnUsage
			;;
	esac
done

if [ "$CURRENT_TIME" -lt "$TIME" ]; then
	if [ -f "$MAIL_SENT" ]; then rm "$MAIL_SENT"; fi
fi

ZPOOL_STATUS=$(zpool status -x)

if [ "$ZPOOL_STATUS" = "all pools are healthy" ] || [ "$ZPOOL_STATUS" = "no pools available" ]; then
	# all OK, send mail once a week
	if [ "$DAY_OF_WEEK" -ne "0" ] && [ "$(date +%u)" -eq "$DAY_OF_WEEK" ] && [ "$CURRENT_TIME" -lt "$TIME" ]; then
		zpool status | mail -s "zpools are healthy on $(hostname)" "$EMAIL"
	fi
else
	if [ ! -f "$MAIL_SENT" ]; then
		zpool status | mail -s "WARNING: zpools are NOT healthy on $(hostname)" "$EMAIL"
		touch "$MAIL_SENT"
	fi
fi
