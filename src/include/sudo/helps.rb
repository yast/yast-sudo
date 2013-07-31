# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/sudo/helps.ycp
# Package:	Configuration of sudo
# Summary:	Help texts of all the dialogs
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: helps.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SudoHelpsInclude
    def initialize_sudo_helps(include_target)
      textdomain "sudo"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"            => _(
          "<p><b><big>Initializing sudo Configuration</big></b><br>\n</p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"           => _(
          "<p><b><big>Saving sudo Configuration</big></b><br>\n</p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          ),
        # User Specification help 1/6
        "spec"            => _(
          "<p><b><big>Rules for sudo</big></b><br>\n" +
            "\tRules for sudo basically determine which commands an user may run \n" +
            "\ton specified hosts (optionally also as what user). Each rule\n" +
            "\tis a tuple consisting of user, host and list of commands, with optional \n" +
            "\tRunAs specification and additional tags. These are summarized \n" +
            "\tin the following table. \n" +
            "\t</p>\n" +
            "\t"
        ) +
          # User Specification help 2/6
          _(
            "<p><b>Users</b> column denotes local or system user or user alias. \n" +
              "\t<b>Hosts</b> column determines, on which hosts, or group \n" +
              "\tof hosts referred to by host alias an user may run specified commands.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          # User Specification help 3/6
          _(
            "<b>RunAs</b> column is an\n" +
              "\toptional parameter, containing user name (or alias) whose access privileges\n" +
              "\twill be used to run commands. <b>NOPASSWD</b> is a tag, determining whether\n" +
              "\tusers need to authorize themselves before running commands.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          # User Specification help 4/6
          _(
            "<p>A set of commands that user can run on specified hosts is summarized \n" +
              "\tin <b>Commands</b> column.  \n" +
              "\t</p>\n" +
              "\t"
          ) +
          # User Specification help 5/6
          _(
            "<p> To add a new rule, click on <b>Add</b> button and fill in appropriate \n" +
              "\tentries. User name, hostname and command list must not be empty.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          # User Specification help 5/6
          _(
            "<p>To edit existing rule, select an entry from the table and click on \n" +
              "\t<b>Edit</b> button. To delete selected entry, click on <b>Delete</b> button.\n" +
              "\t</p> \n" +
              "\t"
          ),
        # Single User Specification help 1/4
        "spec_single"     => _(
          "<p><b>User Name or Alias</b> may be specified by single username (e.g.foo), group name prefixed\n" +
            "\twith '%' (e.g. %bar), or user alias name. If \n" +
            "\tkeyword 'ALL' is used, it stands for any user. Select from existing users, groups and aliases \n" +
            "\tin drop-down menu, or enter your own value. \n" +
            "\t</p>\n" +
            "\t"
        ) +
          _(
            "<p><b>Hostname or Alias</b> entry consists of either hostname(e.g. www.example.com), single IP \n" +
              "\taddress (e.g. 192.168.0.1), IP address combined with netmask, or host alias. If commands may be\n" +
              "\trun on any host, use keyword 'ALL'. Hostname or IP address is matched against your own hostname\n" +
              "\tor IP address, so if you don't intend to share one /etc/sudoers file between multiple machines, \n" +
              "\t'ALL' or 'localhost' entry will be sufficient for almost all purposes. \n" +
              "\t</p>\n" +
              "\t"
          ) +
          # Single User Specification help 2/4
          _(
            "<p><b>RunAs Username or Alias</b> is an optional parameter specifying an user, \n" +
              "\twhose access privileges \n" +
              "\twill be used to execute particular command. If empty, user <b>root</b> is the default\n" +
              "\tone. It can be again single username, groupname prefixed with '%' or run_as alias name\n" +
              "\tSelect from existing users, groups and aliases in drop-down menu, or enter your own value.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          # Single User Specification help 3/4
          _(
            "<p><b>No Password</b> is an optional tag. Normally, users have to authenticate\n" +
              "\tthemselves (i.e. supply their own password, not root's one) before running particular \n" +
              "\tcommand. Set No Password tag to 'Yes' if you want to\n" +
              "\tdisable this authentication\n" +
              "\t</p>\n" +
              "\t"
          ) +
          # Single User Specification help 4/4
          _(
            "<p><b>Commands to Run</b> table is a list of commands (optionally with\n" +
              "\tparameters), directories and command aliases that particular user will be allowed \n" +
              "\tto run. If a directory name is used, any command in that directory can be run. \n" +
              "\tAgain, keyword 'ALL' stands for any command, so use it with care.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          _(
            "To add a new command, click on <b>Add</b> button, fill in command name with optional\n" +
              "\tparameters and click <b>OK</b>. To remove command, select appropriate entry from the table\n" +
              "\tand click on <b>Delete</b> button.\n" +
              "\t"
          ),
        #User Aliases help 1/3
        "user_aliases"    => _(
          "<p><b><big>User Aliases</big></b><br>\n" +
            "\tIn this dialog, you can configure user aliases. User alias is a set of users that is given\n" +
            "\tan unique name. This name is later used to refer to all users in this set in sudo configuration. \n" +
            "\t</p> \n" +
            "\t"
        ) +
          #User Aliases help 2/3
          _(
            "<p>To add a new user alias, click on <b>Add</b> button and fill in appropriate entries. \n" +
              "\tAlias name and list of users in the alias must not be empty. \n" +
              "\t</p>\n" +
              "\t"
          ) +
          #User Aliases help 3/3
          _(
            "<p>To edit existing user alias, select an entry from the table and click on <b>Edit</b>\n" +
              "\tbutton. To delete selected entry, click on <b>Delete</b> button. \n" +
              "\t</p>\n" +
              "\t"
          ),
        #Host Aliases help 1/3
        "host_aliases"    => _(
          "<p><b><big>Host Aliases</big></b><br>\n" +
            "\tIn this dialog, you can configure host aliases. Host alias is a set of hosts that is given\n" +
            "\tan unique name. This name is later used to refer to all hosts in this set in sudo configuration. \n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Host Aliases help 2/3
          _(
            "<p>To add a new host alias, click on <b>Add</b> button and fill in appropriate entries. \n" +
              "\tAlias name and list of hosts in the alias must not be empty. \n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Host Aliases help 3/3
          _(
            "<p>To edit existing host alias, select an entry from the table and click on <b>Edit</b>\n" +
              "\tbutton. To delete selected entry, click on <b>Delete</b> button. \n" +
              "\t</p>\n" +
              "\t"
          ),
        #RunAs Aliases help 1/3
        "runas_aliases"   => _(
          "<p><b><big>RunAs Aliases</big></b><br>\n" +
            "\tIn this dialog, you can configure RunAs aliases. RunAs alias is a set of users that is given\n" +
            "\tan unique name. This name is later used to refer to all users in this set in sudo configuration. \n" +
            "\t</p> \n" +
            "\t"
        ) +
          #RunAs Aliases help 2/3
          _(
            "<p>To add a new RunAs alias, click on <b>Add</b> button and fill in appropriate entries. \n" +
              "\tAlias name and list of users in the alias must not be empty. \n" +
              "\t</p>\n" +
              "\t"
          ) +
          #RunAs Aliases help 3/3
          _(
            "<p>To edit existing RunAs alias, select an entry from the table and click on <b>Edit</b>\n" +
              "\tbutton. To delete selected entry, click on <b>Delete</b> button. \n" +
              "\t</p>\n" +
              "\t"
          ),
        #Command Aliases help 1/3
        "command_aliases" => _(
          "<p><b><big>Command Aliases</big></b><br>\n" +
            "\tIn this dialog, you can configure command aliases. Command alias is a set of commands \n" +
            "\t(optionally with parameters) that is given an unique name. This name is then used to refer\n" +
            "\tto all commands in this set in sudo configuration. \n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Command Aliases help 2/3
          _(
            "<p>To add a new command alias, click on <b>Add</b> button and fill in appropriate entries. \n" +
              "\tAlias name and list of commands in the alias must not be empty. \n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Command Aliases help 3/3
          _(
            "<p>To edit existing command alias, select an entry from the table and click on <b>Edit</b>\n" +
              "\tbutton. To delete selected entry, click on <b>Delete</b> button. \n" +
              "\t</p>\n" +
              "\t"
          ),
        #Single User Alias Help 1/2
        "user_alias"      => _(
          "<p><b><big>User Alias</big></b><br>\n" +
            "\tUser alias consists of one or more users, system groups (prefixed with '%') or other\n" +
            "\tuser aliases. It is given single name (must contain uppercase letters, numbers and underscore\tonly), which is then used to refer to all users in this alias.\n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Single User Alias Help 2/3
          _(
            "<p>Enter unique name into <b>Alias Name</b> text entry. To add users or groups to the\n" +
              "\talias, select user or group name from the drop-down menu and click on <b>Add</b> button.\n" +
              "\tTo remove user from the alias, select appropriate entry from the table, and click on\n" +
              "\t<b>Remove</b> button. To finish the configuration, click <b>OK</b>.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Single User Alias Help 3/3
          _(
            "<b>Note:</b> Alias name must not be empty. Each alias must have at least one member.\n\t"
          ),
        #Single Host Alias Help 1/4
        "host_alias"      => _(
          "<p><b><big>Host Alias</big></b><br>\n" +
            "\tHost alias consists of one or more hostnames, single IP addresses, IP addresses\n" +
            "\tcombined with netmask id dotted quad notation (e.g. 192.168.0.0/255.255.255.0) or\n" +
            "\tCIDR number of bits notation (e.g. 192.168.0.0/24), or other host aliases. It is \n" +
            "\tgiven single name (must contain uppercase letters, numbers and underscore only), which \n" +
            "\tis then used to refer to all hosts in this alias.\n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Single Host Alias Help 2/4
          _(
            "<p>Enter unique name into <b>Alias Name</b> text entry. To add hosts to the\n" +
              "\talias, click on <b>Add</b> button. A pop-up window will appear, where you can enter\n" +
              "\tvalid hostname or IP address and then click <b>OK</b>.\n" +
              "\t<p>\n" +
              "\t"
          ) +
          #Single Host Alias Help 3/4
          _(
            "To remove host from the alias, select appropriate entry from the table, and click on\n" +
              "\t<b>Remove</b> button. To finish the configuration, click <b>OK</b>.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Single Host Alias Help 4/4
          _(
            "<b>Note:</b> Alias name must not be empty. Each alias must have at least one member.\n\t"
          ),
        #Single RunAs Alias Help 1/2
        "runas_alias"     => _(
          "<p><b><big>RunAs Alias</big></b><br>\n" +
            "\tRunAs alias is very similar to User Alias. It consists of one or more users, system groups \n" +
            "\t(prefixed with '%') or other RunAs aliases. It is given single name (must contain \n" +
            "\tuppercase letters, numbers and underscore only), which is then used to refer to all users \n" +
            "\tin this alias.\n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Single User Alias Help 2/3
          _(
            "<p>Enter unique name into <b>Alias Name</b> text entry. To add users or groups to the\n" +
              "\talias, select user or group name from the drop-down menu and click on <b>Add</b> button.\n" +
              "\tTo remove user from the alias, select appropriate entry from the table, and click on\n" +
              "\t<b>Remove</b> button. To finish the configuration, click <b>OK</b>.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Single User Alias Help 2/3
          _(
            "<b>Note:</b> Alias name must not be empty. Each alias must have at least one member.\n\t"
          ),
        #Single Command Alias Help 1/4
        "command_alias"   => _(
          "<p><b><big>Command Alias</big></b><br>\n" +
            "\tCommand Alias is a list of one or more commands (with optional parameters), directories, or\n" +
            "\tother command aliases. It is given single name (must contain uppercase letters, numbers and\n" +
            "\tunderscore only), which is \n" +
            "\tthen used to refer to all commands in this alias. A command can optionally have one or more\n" +
            "\tparameters specified. If so, users can run the command with these parameters only. If a \n" +
            "\tdirectory name is used, any command in that directory can be run.  \n" +
            "\t</p>\n" +
            "\t"
        ) +
          #Single Command Alias Help 2/4
          _(
            "<p>Enter unique name into <b>Alias Name</b> text entry. To add a new command to the alias,\n" +
              "\tclick on <b>Add</b> button.A pop-up window will appear, where you can enter command name\n" +
              "\t(or select one from file browser by clicking on <b>Browse</b> button. Additionally, you can\n" +
              "\tspecify command parameters in <b>Parameters</b> text entry\n" +
              "\t"
          ) +
          #Single Command Alias Help 3/4
          _(
            "To remove command from the alias, select appropriate entry from the table, and click on\n" +
              "\t<b>Remove</b> button. To finish the configuration, click <b>OK</b>.\n" +
              "\t</p>\n" +
              "\t"
          ) +
          #Single Command Alias Help 4/4
          _(
            "<b>Note:</b> Alias name must not be empty. Each alias must have at least one member.\n\t"
          )
      } 

      # EOF
    end
  end
end
