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

# File: include/sudo/helps.ycp
# Package:      Configuration of sudo
# Summary:      Help texts for all the dialogs
# Authors:      Bubli <kmachalkova@suse.cz>
#
module Yast
  module SudoHelpsInclude
    def initialize_sudo_helps(include_target)
      textdomain "sudo"

      # All help texts are here
      @HELPS = {
        # Read dialog help 1/2
        "read" => _(
          "<p><b><big>Initializing sudo Configuration</big></b><br>\n</p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>Safely abort the configuration utility by pressing <b>Abort</b> now.</p>"
          ),
        # Write dialog help 1/2
        "write" => _(
          "<p><b><big>Saving sudo Configuration</big></b><br></p>"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br> " +
              "Abort the save procedure by pressing <b>Abort</b>. " +
              "An additional dialog informs whether it is safe to do so. " +
              "</p>"
          ),

        # User Specification help 1/6
        "spec" => _(
          "<p><b><big>Rules for sudo</big></b><br>" +
            "Rules for sudo basically determine which commands a user may run " +
            "on the specified hosts (optionally also as what user). Each rule " +
            "is a tuple consisting of a user, a host and a list of commands, with an optional " +
            "RunAs specification and additional tags. These are summarized " +
            "in the following table. " +
            "</p>"
        ) +
          # User Specification help 2/6
          _(
            "<p>The <b>Users</b> column specifies a local or system user or user alias. </p>" +
              "<p>The <b>Hosts</b> column determines on which hosts or group " +
              "of hosts referred to by a host alias a user may run the specified commands. " +
              "</p>"
          ) +
          # User Specification help 3/6
          _(
            "<p>The <b>RunAs</b> column is an" +
              "optional parameter containing the user name (or alias) whose access privileges " +
              "will be used to run commands. <b>NOPASSWD</b> is a tag determining whether " +
              "users need to authorize themselves before running commands. " +
              "</p>"
          ) +
          # User Specification help 4/6
          _(
            "<p>A set of commands that user can run on specified hosts is summarized " +
              "in the <b>Commands</b> column. " +
              "</p>"
          ) +
          # User Specification help 5/6
          _(
            "<p>To add a new rule, click the <b>Add</b> button and fill in the appropriate " +
              "fields. User name, hostname and command list must not be empty. " +
              "</p>"
          ) +
          # User Specification help 5/6
          _(
            "<p>To edit an existing rule, select an item from the table and click the " +
              "<b>Edit</b> button. To delete the selected item, click the <b>Delete</b> button. " +
              "</p>"
          ),

        # Single User Specification help 1/4
        "spec_single" => _(
          "<p><b>User Name or Alias</b> may be specified by a single username (e.g.foo), a group name prefixed " +
            "with '%' (e.g. %bar), or a user alias name. " +
            "The 'ALL' keyword can be used to specify any user. " +
            "Select from the existing users, groups and aliases " +
            "in the drop-down menu, or enter your own value. " +
            "</p>"
        ) +
          _(
            "<p><b>Hostname or Alias</b> is either a hostname (e.g. www.example.com), a single IP " +
              "address (e.g. 192.168.0.1), an IP address combined with a netmask, or a host alias. If commands may be " +
              "run on any host, use the 'ALL' keyword. The hostname or IP address is matched against your own hostname " +
              "or IP address, so if you don't intend to share one /etc/sudoers file between multiple machines, " +
              "'ALL' or 'localhost' will be sufficient for almost all purposes. " +
              "</p>"
          ) +
          # Single User Specification help 2/4
          _(
            "<p><b>RunAs Username or Alias</b> is an optional parameter specifying a user " +
              "whose access privileges " +
              "will be used to execute a particular command. If empty, the <b>root</b> user is the default. " +
              "It can be a single username, a groupname prefixed with '%' or a run_as alias name. " +
              "Select from the existing users, groups and aliases in the drop-down menu, or enter your own value. " +
              "</p>"
          ) +
          # Single User Specification help 3/4
          _(
            "<p><b>No Password</b> is an optional tag. Normally, users have to authenticate " +
              "themselves (i.e. supply their own password, not the root password) before running a particular " +
              "command. Set the No Password tag to 'Yes' if you want to " +
              "disable this authentication. " +
              "</p>"
          ) +
          # Single User Specification help 4/4
          _(
            "<p>The <b>Commands to Run</b> table is a list of commands (optionally with " +
              "parameters), directories and command aliases that a particular user will be allowed " +
              "to run. If a directory name is used, any command in that directory can be run. " +
              "The 'ALL' keyword means 'any command', so use it with care. " +
              "</p>"
          ) +
          _(
            "<p>To add a new command, click the <b>Add</b> button, enter the command name with optional " +
              "parameters and click <b>OK</b>. To remove a command, select the appropriate item from the table " +
              "and click the <b>Delete</b> button. " +
              "</p>"
          ),

        # User Aliases help 1/3
        "user_aliases" => _(
          "<p><b><big>User Aliases</big></b><br> " +
            "In this dialog, you can configure user aliases. A user alias is a set of users that is given " +
            "a unique name. This name is later used to refer to all users in this set in the sudo configuration. " +
            "</p>"
        ) +
          # User Aliases help 2/3
          _(
            "<p>To add a new user alias, click the <b>Add</b> button and fill in the appropriate fields. " +
              "The alias name and the list of users in the alias must not be empty. " +
              "</p>"
          ) +
          # User Aliases help 3/3
          _(
            "<p>To edit an existing user alias, select an item from the table and click the <b>Edit</b> " +
              "button. To delete the selected item, click the <b>Delete</b> button. " +
              "</p>"
          ),

        # Host Aliases help 1/3
        "host_aliases" => _(
          "<p><b><big>Host Aliases</big></b><br>" +
            "In this dialog, you can configure host aliases. A host alias is a set of hosts that is given " +
            "a unique name. This name is later used to refer to all hosts in this set in the sudo configuration. " +
            "</p>"
        ) +
          # Host Aliases help 2/3
          _(
            "<p>To add a new host alias, click the <b>Add</b> button and fill in the appropriate fields. " +
              "Alias name and list of hosts in the alias must not be empty. " +
              "</p>"
          ) +
          # Host Aliases help 3/3
          _(
            "<p>To edit an existing host alias, select an item from the table and click the <b>Edit</b> " +
              "button. To delete the selected item, click the <b>Delete</b> button. " +
              "</p>"
          ),

        # RunAs Aliases help 1/3
        "runas_aliases" => _(
          "<p><b><big>RunAs Aliases</big></b><br> " +
            "In this dialog, you can configure RunAs aliases. A RunAs alias is a set of users that is given " +
            "a unique name. This name is later used to refer to all users in this set in the sudo configuration. " +
            "</p>"
        ) +
          # RunAs Aliases help 2/3
          _(
            "<p>To add a new RunAs alias, click the <b>Add</b> button and fill in the appropriate fields. " +
              "Alias name and list of users in the alias must not be empty. " +
              "</p>"
          ) +
          # RunAs Aliases help 3/3
          _(
            "<p>To edit an existing RunAs alias, select an item from the table and click the <b>Edit</b> " +
              "button. To delete the selected item, click the <b>Delete</b> button. " +
              "</p>"
          ),

        # Command Aliases help 1/3
        "command_aliases" => _(
          "<p><b><big>Command Aliases</big></b><br> " +
            "In this dialog, you can configure command aliases. A command alias is a set of commands " +
            "(optionally with parameters) that is given a unique name. This name is then used to refer " +
            "to all commands in this set in the sudo configuration. " +
            "</p>"
        ) +
          # Command Aliases help 2/3
          _(
            "<p>To add a new command alias, click the <b>Add</b> button and fill in the appropriate fields. " +
              "Alias name and list of commands in the alias must not be empty. " +
              "</p>"
          ) +
          # Command Aliases help 3/3
          _(
            "<p>To edit an existing command alias, select an item from the table and click the <b>Edit</b> " +
              "button. To delete the selected item, click the <b>Delete</b> button. " +
              "</p>"
          ),

        # Single User Alias Help 1/2
        "user_alias" => _(
          "<p><b><big>User Alias</big></b><br>" +
            "A user alias consists of one or more users, system groups (prefixed with '%') or other" +
            "user aliases. It is given single name (must contain uppercase letters, numbers and " +
            "underscore only), which is then used to refer to all users in this alias." +
            "</p>"
        ) +
          # Single User Alias Help 2/3
          _(
            "<p>Enter a unique name into <b>Alias Name</b> input field. To add users or groups to the " +
              "alias, select user or group name from the drop-down menu and click the <b>Add</b> button. " +
              "To remove user from the alias, select the appropriate item from the table, and click the " +
              "<b>Remove</b> button. To finish the configuration, click <b>OK</b>. " +
              "</p>"
          ) +
          # Single User Alias Help 3/3
          _(
            "<p><b>Note:</b> Alias name must not be empty. Each alias must have at least one member.</p>"
          ),

        # Single Host Alias Help 1/4
        "host_alias" => _(
          "<p><b><big>Host Alias</big></b><br> " +
            "A host alias consists of one or more hostnames, single IP addresses, IP addresses " +
            "combined with netmask id dotted quad notation (e.g. 192.168.0.0/255.255.255.0) or " +
            "CIDR number of bits notation (e.g. 192.168.0.0/24), or other host aliases. It is " +
            "given single name (must contain uppercase letters, numbers and underscore only), which " +
            "is then used to refer to all hosts in this alias. " +
            "</p>"
        ) +
          # Single Host Alias Help 2/4
          _(
            "<p>Enter a unique name into the <b>Alias Name</b> input field. To add hosts to the" +
              "alias, click the <b>Add</b> button. A pop-up window will appear, where you can enter" +
              "a valid hostname or IP address and then click <b>OK</b>." +
              "<p>"
          ) +
          # Single Host Alias Help 3/4
          _(
            "<p>To remove host from the alias, select the appropriate item from the table, and click the " +
              "<b>Remove</b> button. To finish the configuration, click <b>OK</b>. " +
              "</p>"
          ) +
          # Single Host Alias Help 4/4
          _(
            "<p><b>Note:</b> Alias name must not be empty. Each alias must have at least one member.</p>"
          ),
        # Single RunAs Alias Help 1/2
        "runas_alias" => _(
          "<p><b><big>RunAs Alias</big></b><br> " +
            "A RunAs alias is very similar to a User alias. It consists of one or more users, system groups " +
            "(prefixed with '%') or other RunAs aliases. It is given single name (must contain " +
            "uppercase letters, numbers and underscore only), which is then used to refer to all users " +
            "in this alias." +
            "</p>"
        ) +
          # Single User Alias Help 2/3
          _(
            "<p>Enter a unique name into the <b>Alias Name</b> input field. To add users or groups to the " +
              "alias, select user or group name from the drop-down menu and click the <b>Add</b> button. " +
              "To remove user from the alias, select the appropriate item from the table, and click the " +
              "<b>Remove</b> button. To finish the configuration, click <b>OK</b>. " +
              "</p>"
          ) +
          # Single User Alias Help 2/3
          _(
            "<p><b>Note:</b> The alias name must not be empty. Each alias must have at least one member.</p>"
          ),

        # Single Command Alias Help 1/4
        "command_alias" => _(
          "<p><b><big>Command Alias</big></b><br> " +
            "A Command Alias is a list of one or more commands (with optional parameters), directories, or " +
            "other command aliases. It is given single name (must contain uppercase letters, numbers and " +
            "underscore only), which is " +
            "then used to refer to all commands in this alias. A command can optionally have one or more " +
            "parameters specified. If so, users can run the command with these parameters only. If a " +
            "directory name is used, any command in that directory can be run. " +
            "</p>"
        ) +
          # Single Command Alias Help 2/4
          _(
            "<p>Enter a unique name into the <b>Alias Name</b> input field. To add a new command to the alias, " +
              "click the <b>Add</b> button.A pop-up window will appear, where you can enter command name " +
              "(or select one from file browser by clicking on <b>Browse</b> button. Additionally, you can " +
              "specify command parameters in <b>Parameters</b> input field " +
              "</p>"
          ) +
          # Single Command Alias Help 3/4
          _(
            "To remove command from the alias, select the appropriate item from the table, and click the " +
              "<b>Remove</b> button. To finish the configuration, click <b>OK</b>. " +
              "</p>"
          ) +
          # Single Command Alias Help 4/4
          _(
            "<p><b>Note:</b> The alias name must not be empty. Each alias must have at least one member.</p>"
          )
      }

      # EOF
    end
  end
end
