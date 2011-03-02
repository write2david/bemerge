#!/bin/bash

# Modified from:  http://en.gentoo-wiki.com/wiki/Portage_TMPDIR_on_tmpfs
# Store this file in /root and then do this:    ln -s /root/bemerge.sh /usr/local/sbin/bemerge &&  chmod u+x /usr/local/sbin/bemerge

. /etc/init.d/functions.sh


compile() {
	echo ""
	echo "  Welcome to *bemerge*"
	echo ""
	einfo "Running:  emerge --keep-going=y --jobs=2 ${*} ...\n"

	if [ -f /usr/bin/time ]
		then
			/usr/bin/time -f "\n\nEMERGE TOTALS...  Time: %E.  Avg CPU: %P.  Avg memory use: %KK" emerge --keep-going=True --jobs=3 ${*}
		else
			echo "/usr/bin/time not found, exiting." && exit
	fi
}


notice() {
                # String all these lines/commands together with "&&" so that if the user hits Ctrl-C anytime during the post-emerge process, then the whole post-emerge process dies.  But this method doesn't work on lines that have pipes  ("|") and so don't use it on those lines.
		echo "" && \
		einfo "Cleaning up non-local locale files..." && \
                if [ -f /usr/bin/localepurge ];
			then
				localepurge | grep freed
			else
				echo "/usr/bin/localepurge not found, exiting." && exit
		fi
		#
		einfo "Removing unneeded Portage install files..." && \
		# -d is not too destructive and without it you can have lots of unneccesary source code install files building up
		eclean-dist -d && \
		#
		einfo "Updating list of kernel modules provided by installed packages..." && \
		# From: http://www.gentoo.org/doc/en/kernel-upgrade.xml#doc_chap6
		# must emerge module-rebuild for this to work
		[ -f /usr/sbin/module-rebuild ] && module-rebuild populate > /dev/null && \
		echo "" && \
		echo "" &&\
		einfo "You may also want to run:" && \
		einfo "" && \
		einfo "revdep-rebuild -- -av      (reverse dependency check)" && \
		einfo "dispatch-conf | etc-update (update configuration files)" && \
		einfo "module-rebuild rebuild     (rebuild kernel modules provided by ebuilds)" && \
		einfo "emerge --prune -av         (remove old versions from multiple-slots" && \
		einfo "emerge --depclean -av      (remove packages not needed anymore)" && \
		einfo "python-updater             (for any updates of python)" && \
		einfo "perl-cleaner --all         (for any updates of perl)" && \
		einfo "java-check-environment     (for any java installs)" && \
		einfo "eselect                    (for any updates involving choices)" && \
		einfo "emaint -f all              (system health checks and fixes)" && \
		einfo "eix-test-obsolete detailed (for checking your /etc/portage files for unused entries)" && \
		einfo "elogv [or] eread           (review elog messages for newly installed packages)" && \
		einfo "mysql_upgrade -p           (for any mySQL program upgrades -- then restart mysqld)" && \
		#
		# next line requires package "portage-utils"
		einfo "emerge -1av \$(qlist -IC x11-drivers/)   (rebuild drivers after xorg-sever upgrade)" && \
		#
		echo "" && \
		#	The next line came from content on:  http://www.gentoo.org/doc/en/gcc-upgrading.xml
		einfo "If you've upgraded GCC, then do:"
		echo "     gcc-config i686-pc-linux-gnu-X.X.X   (substitute new version for X.X.X)" && \
		echo "     env-update && source /etc/profile" && \
		echo "     emerge -1av libtool && emerge -eav system && emerge -eav world" && \
		echo "     (then remove the old version of GCC)" && \
		echo "" && \
		einfo "Occasionally, run this:  'emerge -DavuNt1e world'" && \
		echo  "   This shows what upgrades have been missed when doing a world upgrade" && \
		echo  "   (which may also prohibit 'emerge --prune |--depclean' from working" &&\
		echo "" && \
		echo "" && \
		#
		# From: http://www.gentoo.org/news/en/gmn/20080930-newsletter.xml#doc_chap4_sect3
		# Adding "+c 0" to the "lsof" command in order to get the full filename.
		# Adding "| pr -a -t -2" in order to put it into two columns
		# must emerge lsof in order for this to work
		einfo "The following *in-use* files (if any) have been DELETED while emerge ran." && \
		echo  "   (you may want to restart related programs)..." && \
		if [ -f /usr/bin/lsof ];
			then
				lsof +c 0 | grep 'DEL.*lib' | cut -f 1 -d ' ' | sort -u | pr -a -t -2
		fi && \
		# requires the checkrestart package to be installed:
		echo ""
		einfo "If there are any init scripts for these, they are here:" && \
		checkrestart| sed -n "/^These are the init scripts/,/These processes do not seem/p" | grep -v "These processes" | grep -v "These are the init"
		echo ""
	}


		
# Run emerge
compile $@

# Display info
notice
