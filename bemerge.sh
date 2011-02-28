#!/bin/bash

# Modified from:  http://en.gentoo-wiki.com/wiki/Portage_TMPDIR_on_tmpfs
# Store this file in /root and then do this:    ln -s /root/bemerge.sh /usr/local/sbin/bemerge &&  chmod u+x /usr/local/sbin/bemerge

. /etc/init.d/functions.sh


compile() {
	echo ""
	echo "  Welcome to *bemerge*"
	echo ""
	einfo "Running:  emerge --keep-going=True --jobs=2 ${*} ...\n"
	# Run the emerge command, with two additional options
	emerge --keep-going=True --jobs=2 ${*}
}


notice() {
                # String all these lines/commands together with "&&" so that if the user hits Ctrl-C anytime during the post-emerge process, then the whole post-emerge process dies.  But this method doesn't work on lines that have pipes  ("|") and so don't use it on those lines.
		einfo "" && \
		einfo "Clean up: non-local locale files..." && \
                localepurge | grep freed
		#
		einfo "Remove unneeded Portage install files..." && \
		# -d is not too destructive and without it you can have lots of unneccesary source code install files building up
		eclean-dist -d && \
		#
		einfo "Updating list of kernel modules provided by installed packages..." && \
		# From: http://www.gentoo.org/doc/en/kernel-upgrade.xml#doc_chap6
		# must emerge module-rebuild for this to work
		[ -f /usr/sbin/module-rebuild ] && module-rebuild populate > /dev/null && \
		einfo "" && \
		einfo "" &&\
		einfo "You may also want to run:" && \
		einfo "" && \
		einfo "revdep-rebuild -- -av      (reverse dependency check)" && \
		einfo "dispatch-conf              (update configuration files)" && \
		einfo "module-rebuild rebuild     (rebuild kernel modules provided by ebuilds)" && \
		einfo "emerge --prune -av         (remove old versions from multiple-slots" && \
		einfo "emerge --depclean -av      (remove packages not needed anymore)" && \
		einfo "python-updater             (for any updates of python)" && \
		einfo "perl-cleaner --all         (for any updates of perl)" && \
		einfo "java-check-environment     (for any java installs)" && \
		einfo "eselect                    (for any updates involving choices)" && \
		einfo "emaint -f all              (system health checks/maintenance)" && \ 
		einfo "eix-test-obsolete detailed (for checking your /etc/portage files for unused entries)" && \
		einfo "elogv [or] eread           (review elog messages for newly installed packages)" && \
		einfo "mysql_upgrade -p           (for any mySQL program upgrades -- then restart mysqld)" && \
		#
		# next line requires package "portage-utils"
		einfo "emerge -1av \$(qlist -IC x11-drivers/)   (to rebuild drivers, after upgrading xorg-sever)" && \
		#
		einfo "" && \
		#	The next line came from content on:  http://www.gentoo.org/doc/en/gcc-upgrading.xml
		einfo "If you've upgraded GCC, then do:  gcc-config i686-pc-linux-gnu-X.X.X && env-update && source /etc/profile       (use your new version for X.X.X)" && \
		einfo "   ... and then:  emerge -1av libtool && emerge -eav system && emerge -eav world" && \
		einfo "   ... and then remove the old version of GCC." && \
		einfo "" && \
		einfo "Occasionally, do this to see what upgrades have been missed when doing a world upgrade, which may also prohibit emerge --prune/--depclean from working:  'emerge -DavuNt1e world'." && \
		einfo "" && \
		einfo "" && \
		#
		# From: http://www.gentoo.org/news/en/gmn/20080930-newsletter.xml#doc_chap4_sect3
		# must emerge lsof in order for this to work
		einfo "The following *in-use* files have been DELETED while emerge ran." && \
		einfo "You may want to restart related programs (if none are listed, then nothing to worry about)..." && \
		[ -f /usr/bin/lsof ] && lsof | grep 'DEL.*lib' | cut -f 1 -d ' ' | sort -u 
		# requires the checkrestart package to be installed:
		checkrestart
		einfo "" 
		einfo ""
	}


		
# Run emerge
compile $@

# Display info
notice
