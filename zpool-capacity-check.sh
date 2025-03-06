#!/bin/sh
# checks zpools for capacity exhaustion

EMAIL=root
MAIL_SENT="/tmp/zpool-capacity-check-mail.lock"
DAY_OF_WEEK=7
TIME=0005
CURRENT_TIME=$(date +%H%M)
LIMIT=85

# help
fnUsage() {
	echo "USAGE: $(basename $0) [options]" 1>&2;
	echo "  -d <day>  : day of week when to send a capacity message, default=7 (sunday). Set to 0 to disable." 1>&2;
	echo "  -h        : show this help message" 1>&2;
	echo "  -m <email>: send notification to this email address, default=root" 1>&2;
	echo "  -t <time> : delete send lock file if started before this time, formatted as hhmm, default=0005" 1>&2;
	echo "  -l <limit>: limit in %, default=85" 1>&2;
	exit 1;
}

# arguments
while getopts "d:hm:t:l:" OPT; do
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
		l)
			LIMIT="$OPTARG"
			;;
		h|*)
			fnUsage
			;;
	esac
done

if [ "$CURRENT_TIME" -lt "$TIME" ]; then
	if [ -f "$MAIL_SENT" ]; then rm "$MAIL_SENT"; fi
fi

ZPOOL_LIST_CMD="zpool list -o name,capacity"
ZPOOL_LIST=$(eval "$ZPOOL_LIST_CMD")
ZPOOL_CAPACITY=$(echo "$ZPOOL_LIST" | awk -v limit="$LIMIT" '$2+0 > limit {print $0}')

if [ "$ZPOOL_CAPACITY" = "" ]; then
	# all OK, send mail once a week
	if [ "$DAY_OF_WEEK" -ne "0" ] && [ "$(date +%u)" -eq "$DAY_OF_WEEK" ] && [ "$CURRENT_TIME" -lt "$TIME" ]; then
		printf "Warn limit: %s%%\n\n# %s\n%s" "$LIMIT" "$ZPOOL_LIST_CMD" "$ZPOOL_LIST" | mail -s "zpools are below capacity limit on $(hostname)" "$EMAIL"
	fi
else
	if [ ! -f "$MAIL_SENT" ]; then
		printf "Warn limit: %s%%\n\n# %s\n%s" "$LIMIT" "$ZPOOL_LIST_CMD" "$ZPOOL_LIST" | mail -s "WARNING: zpools are ABOVE the capacity limit on $(hostname)" "$EMAIL"
		touch "$MAIL_SENT"
	fi
fi
