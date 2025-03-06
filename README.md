# zfs-scripts

Just a few scripts, that I use on my servers, that have ZFS pools.

Tested on:

- FreeBSD
- Proxmox

## zpool-scrub-all.sh

Run this script to scrub all ZFS pools at once instead of specifying each pool on it's own.

Example cron entry:

```crontab
# min	hour	day	month	weekday	command
0	2	*	*	5	/root/zfs-scripts/zpool-scrub-all.sh
```

## zpool-status-check.sh

Unfortunately, there is no advanced technique like illumos Fault Management Architecture (FMA) on FreeBSD. So at least run this script to check ZFS pool healthiness and send a notification mail if a pool is not healthy. Mail is send only once a day. Should do the job well enough.

Also by default a weekly mail with output of `zpool status` is send if run on Sunday between 00:00 and 00:05 o'clock (made for use with cron).

By default mail is send to *root*. You can specify any recipient with argument *-m*.

Usage:

```txt
USAGE: zpool-status-check.sh [options]
  -d <day>  : day of week when to send a healthy message, default=7 (sunday). Set to 0 to disable.
  -h        : show this help message
  -m <email>: send notification to this email address, default=root
  -t <time> : delete send lock file if started before this time, formatted as hhmm, default=0005
```

Example cron entry:

```crontab
# min	hour	day	month	weekday	command
*/5	*	*	*	*	/root/zfs-scripts/zpool-status-check.sh -m me@example.com
```

## zpool-capacitiy-check

Checks all zpools, if capacity (disk usage) exceeds a limit. It sends a notification mail if a pool is above the limit.

Usage:

```txt
USAGE: zpool-capacity-check.sh [options]
  -d <day>  : day of week when to send a capacity message, default=7 (sunday). Set to 0 to disable.
  -h        : show this help message
  -m <email>: send notification to this email address, default=root
  -t <time> : delete send lock file if started before this time, formatted as hhmm, default=0005
  -l <limit>: limit in %, default=85
```

Example cron entry:

```crontab
# min	hour	day	month	weekday	command
*/5	*	*	*	*	/root/zfs-scripts/zpool-capacity-check.sh -m me@example.com
```
