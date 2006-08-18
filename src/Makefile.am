# Makefile.am for sudo/src

yncludedir = @yncludedir@/sudo

client_DATA =			\
	sudo.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	dialog-spec.ycp     \
	dialog-user.ycp     \
	dialog-runas.ycp     \
	dialog-host.ycp     \
	dialog-cmnd.ycp     \
	complex.ycp

desktop_DATA =			\
	sudo.desktop

module_DATA =			\
	Sudo.ycp		

# create a symlink for local build, #145327
sudo:
	ln -sf . $@
ycpchook = sudo

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
