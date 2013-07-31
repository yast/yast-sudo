# Sources for sudo

module_DATA = \
  modules/Sudo.rb

client_DATA = \
  clients/sudo.rb

yncludedir = @yncludedir@/sudo
ynclude_DATA = \
  include/sudo/dialog-cmnd.rb \
  include/sudo/wizards.rb \
  include/sudo/dialog-spec.rb \
  include/sudo/dialog-user.rb \
  include/sudo/dialog-runas.rb \
  include/sudo/dialogs.rb \
  include/sudo/complex.rb \
  include/sudo/dialog-host.rb \
  include/sudo/helps.rb

scrconf_DATA = \
  scrconf/sudo.scr

agent_SCRIPTS = \
  servers_non_y2/ag_etc_sudoers

desktop_DATA = \
  desktop/sudo.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(agent_SCRIPTS) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common