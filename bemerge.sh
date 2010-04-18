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
		einfo "Clean up: remove non-English/French locale files & remove unneeded Portage install files..."
                localepurge | grep freed
		#
		# -d is not too destructive and without it you can have lots of unneccesary source code install files building up
		eclean-dist -d && \
		#
		einfo "Updating list of modules provided by ebuilds..." && \
		# From: http://www.gentoo.org/doc/en/kernel-upgrade.xml#doc_chap6
		# must emerge module-rebuild for this to work
		[ -f /usr/sbin/module-rebuild ] && module-rebuild populate > /dev/null && \
		einfo "" && \
		einfo "" &&\
		einfo "You may also want to run:" && \
		einfo "         revdep-rebuild -- -av  (reverse dependency check)" && \
		einfo "         dispatch-conf  (update configuration files)" && \
		einfo "         module-rebuild rebuild  (rebuild kernel modules provided by ebuilds)" && \
		einfo "         bemerge --prune -av  (remove old versions from multiple-slots" && \
		einfo "         eclean-dist -d (to only keep minimum for reinstallation)." && \
		einfo "         bemerge --depclean -av  (remove packages not needed anymore)" && \
		einfo "         python-updater  (for any updates of python)" && \
		einfo "         eselect  (for any updates of kernel, python, java)" && \
		einfo "         elogv or  eread  (review elog messages for newly installed packages)" && \
		einfo "" && \
		#	The next line came from content on:  http://www.gentoo.org/doc/en/gcc-upgrading.xml
		einfo "         If you've upgraded GCC, then do:  gcc-config i686-pc-linux-gnu-X.X.X && env-update && source /etc/profile     (use your new version for X.X.X)" && \
		einfo "            ... and then:  emerge --oneshot -av libtool && emerge -eav system && emerge -eav world" && \
		einfo "            ... and then remove the old version of GCC." && \
		einfo "" && \
		einfo "" && \
		#
		# From: http://www.gentoo.org/news/en/gmn/20080930-newsletter.xml#doc_chap4_sect3
		# must emerge lsof in order for this to work
		einfo "The following *in-use* files have been DELETED while emerge ran." && \
		einfo "You may want to restart related programs (if none are listed, then nothing to worry about)..." && \
		[ -f /usr/bin/lsof ] && lsof | grep 'DEL.*lib' | cut -f 1 -d ' ' | sort -u 
		einfo "" 
		einfo ""
	}


		
# Run emerge
compile $@

# Display info
notice
