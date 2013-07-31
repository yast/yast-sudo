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

# File:	include/sudo/complex.ycp
# Package:	Configuration of sudo
# Summary:	Dialogs definitions
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: complex.ycp 29363 2006-03-24 08:20:43Z mzugec $
module Yast
  module SudoComplexInclude
    def initialize_sudo_complex(include_target)
      Yast.import "UI"

      textdomain "sudo"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "Sudo"
      Yast.import "Report"
      Yast.import "Address"
      Yast.import "Netmask"
      Yast.import "FileUtils"


      Yast.include include_target, "sudo/helps.rb"

      @current_alias_name = ""
      @current_spec_idx = -1
      @initial_screen = "user_specs"
    end

    def EnableDisableButtons(edit_button, delete_button, items)
      items = deep_copy(items)
      UI.ChangeWidget(Id(edit_button), :Enabled, items != [])
      UI.ChangeWidget(Id(delete_button), :Enabled, items != [])

      nil
    end

    def ValidateHost(hostname)
      netmask = ""

      if Builtins.findfirstof(hostname, "/") != nil
        tmp = Builtins.splitstring(hostname, "/")
        hostname = Ops.get(tmp, 0, "")
        netmask = Ops.get(tmp, 1, "")

        if !Netmask.Check(netmask)
          netmask = ""
          Popup.Error(
            _(
              "A valid netmask is either in dotted quad notation \n" +
                "(4 integers in the range 128 - 255 separated by dots) \n" +
                "or single integer in the range 0 - 32"
            )
          )
          return false
        end
      end
      if !Address.Check(hostname)
        Popup.Error(Address.Valid4)
        return false
      end
      true
    end

    def AddHostDialog(host)
      new_host = host

      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          Frame(
            _("Add New Host to the Alias"),
            MarginBox(
              1,
              1,
              InputField(Id("host_name"), _("Hostname or Network"), new_host)
            )
          ),
          ButtonBox(
            PushButton(Id(:ok), Opt(:default, :okButton), Label.OKButton),
            PushButton(Id(:cancel), Opt(:cancelButton), Label.CancelButton)
          )
        )
      )

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :ok
          new_host = Convert.to_string(UI.QueryWidget(Id("host_name"), :Value))

          if !ValidateHost(new_host)
            UI.SetFocus(Id("host_name"))
            next
          end
          break
        elsif ret == :cancel
          break
        end
      end
      UI.CloseDialog
      new_host
    end

    def AddUserDialog(users)
      users = deep_copy(users)
      new_user = ""

      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          Frame(
            _("Add New User to the Alias"),
            MarginBox(
              1,
              1,
              ComboBox(
                Id("user_name"),
                _("Local and System Users (Groups)"),
                users
              )
            )
          ),
          ButtonBox(
            PushButton(Id(:ok), Opt(:default, :okButton), Label.OKButton),
            PushButton(Id(:cancel), Opt(:cancelButton), Label.CancelButton)
          )
        )
      )

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :ok
          new_user = Convert.to_string(UI.QueryWidget(Id("user_name"), :Value))
          break
        elsif ret == :cancel
          break
        end
      end
      UI.CloseDialog
      new_user
    end

    def ValidateCommand(cmd)
      if FileUtils.Exists(cmd) ||
          Builtins.contains(Sudo.GetAliasNames("command"), cmd) ||
          cmd == "ALL"
        return true
      else
        Popup.Error(
          Builtins.sformat(
            _("File, directory or command alias '%1' does not exist."),
            cmd
          )
        )
        return false
      end
    end

    def AddCommandDialog(c, p)
      new_command = ""

      items = Sudo.GetAliasNames("command")

      items = Builtins.prepend(items, "ALL")

      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          Frame(
            _("Add new command with optional parameters"),
            VBox(
              VSpacing(0.5),
              VBox(
                HBox(
                  MinWidth(
                    40,
                    ComboBox(Id("cmd"), Opt(:editable), _("Command"), items)
                  ),
                  VBox(VSpacing(1.1), PushButton(Id("browse_c"), _("Browse")))
                ),
                Left(TextEntry(Id("params"), _("Parameters (optional)"), p))
              ),
              VSpacing(0.5)
            )
          ),
          VSpacing(0.5),
          ButtonBox(
            PushButton(Id(:ok), Opt(:default, :okButton), Label.OKButton),
            PushButton(Id(:cancel), Opt(:cancelButton), Label.CancelButton)
          )
        )
      )

      UI.ChangeWidget(Id("cmd"), :Value, c)

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :ok
          cmd = Convert.to_string(UI.QueryWidget(Id("cmd"), :Value))
          params = Convert.to_string(UI.QueryWidget(Id("params"), :Value))

          if !ValidateCommand(cmd)
            UI.SetFocus(Id("cmd"))
            next
          end

          new_command = Ops.add(Ops.add(cmd, " "), params)
          break
        elsif ret == :cancel
          break
        elsif ret == "browse_c"
          new_cmd = UI.AskForExistingFile("/", "*", "Choose a command")
          UI.ChangeWidget(Id("cmd"), :Value, new_cmd)
        end
      end
      UI.CloseDialog
      new_command
    end

    def UpdateCmdList(members)
      members = deep_copy(members)
      idx = 0
      items = []

      Builtins.foreach(members) do |it|
        pos = Builtins.findfirstof(it, " \t")
        cmd = ""
        param = ""
        if pos != nil
          cmd = Builtins.substring(it, 0, pos)
          param = Builtins.substring(it, Ops.add(pos, 1))
        else
          cmd = it
          param = ""
        end
        items = Builtins.add(items, Item(Id(idx), cmd, param))
        idx = Ops.add(idx, 1)
      end

      deep_copy(items)
    end
    # Read settings dialog (currently unused)
    #  * @return `abort if aborted and `next otherwisea
    #  *
    #     symbol ReadDialog() {
    # 	Wizard::RestoreHelp(HELPS["read"]:"");
    #
    # 	//Check if user is root
    # 	if (!Confirm::MustBeRoot())
    # 		return `abort;
    #
    # 	boolean ret = Sudo::Read();
    # 	return ret ? `next : `abort;
    #     }

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      ret = Sudo.Write

      #yes-no popup - an error occured when saving the configuration
      if !ret &&
          Popup.YesNo(
            _("Saving sudoer's configuration failed. Change the settings?")
          )
        return :back
      end
      ret ? :next : :abort
    end
  end
end
