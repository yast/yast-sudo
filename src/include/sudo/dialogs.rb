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

# File:	include/sudo/dialogs.ycp
# Package:	Configuration of sudo
# Summary:	Dialogs definitions
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: dialogs.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SudoDialogsInclude
    def initialize_sudo_dialogs(include_target)
      Yast.import "UI"

      textdomain "sudo"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Sudo"
      Yast.import "DialogTree"

      Yast.include include_target, "sudo/helps.rb"
      Yast.include include_target, "sudo/complex.rb"


      @sudo_caption = _("Sudo Configuration")

      @widgets_handling = {
        "UserSpecifications" => {
          "widget"        => :custom,
          "custom_widget" => VBox(),
          "init"          => fun_ref(method(:InitUserSpecs), "void (string)"),
          "handle"        => fun_ref(
            method(:HandleUserSpecs),
            "symbol (string, map)"
          ),
          "help"          => Ops.get_string(@HELPS, "spec", "")
        },
        "UserAliases"        => {
          "widget"        => :custom,
          "custom_widget" => VBox(),
          "init"          => fun_ref(method(:InitUserAliases), "void (string)"),
          "handle"        => fun_ref(
            method(:HandleUserAliases),
            "symbol (string, map)"
          ),
          "help"          => Ops.get_string(@HELPS, "user_aliases", "")
        },
        "RunAsAliases"       => {
          "widget"        => :custom,
          "custom_widget" => VBox(),
          "init"          => fun_ref(method(:InitRunAsAliases), "void (string)"),
          "handle"        => fun_ref(
            method(:HandleRunAsAliases),
            "symbol (string, map)"
          ),
          "help"          => Ops.get_string(@HELPS, "runas_aliases", "")
        },
        "HostAliases"        => {
          "widget"        => :custom,
          "custom_widget" => VBox(),
          "init"          => fun_ref(method(:InitHostAliases), "void (string)"),
          "handle"        => fun_ref(
            method(:HandleHostAliases),
            "symbol (string, map)"
          ),
          "help"          => Ops.get_string(@HELPS, "host_aliases", "")
        },
        "CommandAliases"     => {
          "widget"        => :custom,
          "custom_widget" => VBox(),
          "init"          => fun_ref(method(:InitCmndAliases), "void (string)"),
          "handle"        => fun_ref(
            method(:HandleCmndAliases),
            "symbol (string, map)"
          ),
          "help"          => Ops.get_string(@HELPS, "command_aliases", "")
        }
      }

      @functions = { :abort => fun_ref(Sudo.method(:Abort), "boolean ()") }

      @tabs = {
        "user_specs"    => {
          "contents"        => VBox(
            HBox(
              Table(
                Id("table_user_spec"),
                Opt(:keepSorting),
                Header(
                  _("Users"),
                  _("Hosts"),
                  _("RunAs"),
                  _("NOPASSWD"),
                  _("Commands")
                ),
                []
              ),
              VBox(
                PushButton(Id("up"), _("Up")),
                PushButton(Id("down"), _("Down"))
              )
            ),
            Left(
              HBox(
                PushButton(
                  Id("add_spec"),
                  Opt(:key_F3),
                  Ops.add(Ops.add(" ", Label.AddButton), " ")
                ),
                PushButton(
                  Id("edit_spec"),
                  Opt(:key_F4),
                  Ops.add(Ops.add(" ", Label.EditButton), " ")
                ),
                PushButton(
                  Id("delete_spec"),
                  Opt(:key_F5),
                  Ops.add(Ops.add(" ", Label.DeleteButton), " ")
                )
              )
            )
          ),
          "caption"         => Ops.add(
            Ops.add(@sudo_caption, ": "),
            _("Rules for sudo")
          ),
          "tree_item_label" => _("Rules for sudo "),
          "widget_names"    => ["UserSpecifications"]
        },
        "user_aliases"  => {
          "contents"        => VBox(
            Table(
              Id("table_user_aliases"),
              Opt(:keepSorting),
              Header(_("Alias Name"), _("Members")),
              []
            ),
            Left(
              HBox(
                PushButton(
                  Id("add_user_alias"),
                  Opt(:key_F3),
                  Ops.add(Ops.add(" ", Label.AddButton), " ")
                ),
                PushButton(
                  Id("edit_user_alias"),
                  Opt(:key_F4),
                  Ops.add(Ops.add(" ", Label.EditButton), " ")
                ),
                PushButton(
                  Id("delete_user_alias"),
                  Opt(:key_F5),
                  Ops.add(Ops.add(" ", Label.DeleteButton), " ")
                )
              )
            )
          ),
          "caption"         => Ops.add(
            Ops.add(@sudo_caption, ": "),
            _("User Aliases")
          ),
          "tree_item_label" => _("User Aliases"),
          "widget_names"    => ["UserAliases"]
        },
        "runas_aliases" => {
          "contents"        => VBox(
            Table(
              Id("table_runas_aliases"),
              Opt(:keepSorting),
              Header(_("Alias Name"), _("Members")),
              []
            ),
            Left(
              HBox(
                PushButton(
                  Id("add_runas_alias"),
                  Opt(:key_F3),
                  Ops.add(Ops.add(" ", Label.AddButton), " ")
                ),
                PushButton(
                  Id("edit_runas_alias"),
                  Opt(:key_F4),
                  Ops.add(Ops.add(" ", Label.EditButton), " ")
                ),
                PushButton(
                  Id("delete_runas_alias"),
                  Opt(:key_F5),
                  Ops.add(Ops.add(" ", Label.DeleteButton), " ")
                )
              )
            )
          ),
          "caption"         => Ops.add(
            Ops.add(@sudo_caption, ": "),
            _("RunAs Aliases")
          ),
          "tree_item_label" => _("RunAs Aliases"),
          "widget_names"    => ["RunAsAliases"]
        },
        "host_aliases"  => {
          "contents"        => VBox(
            Table(
              Id("table_host_aliases"),
              Opt(:keepSorting),
              Header(_("Alias Name"), _("Hosts")),
              []
            ),
            Left(
              HBox(
                PushButton(
                  Id("add_host_alias"),
                  Opt(:key_F3),
                  Ops.add(Ops.add(" ", Label.AddButton), " ")
                ),
                PushButton(
                  Id("edit_host_alias"),
                  Opt(:key_F4),
                  Ops.add(Ops.add(" ", Label.EditButton), " ")
                ),
                PushButton(
                  Id("delete_host_alias"),
                  Opt(:key_F5),
                  Ops.add(Ops.add(" ", Label.DeleteButton), " ")
                )
              )
            )
          ),
          "caption"         => Ops.add(
            Ops.add(@sudo_caption, ": "),
            _("Host Aliases")
          ),
          "tree_item_label" => _("Host Aliases"),
          "widget_names"    => ["HostAliases"]
        },
        "cmnd_aliases"  => {
          "contents"        => VBox(
            Table(
              Id("table_command_aliases"),
              Opt(:keepSorting),
              Header(_("Alias Name"), _("Commands")),
              []
            ),
            Left(
              HBox(
                PushButton(
                  Id("add_command_alias"),
                  Opt(:key_F3),
                  Ops.add(Ops.add(" ", Label.AddButton), " ")
                ),
                PushButton(
                  Id("edit_command_alias"),
                  Opt(:key_F4),
                  Ops.add(Ops.add(" ", Label.EditButton), " ")
                ),
                PushButton(
                  Id("delete_command_alias"),
                  Opt(:key_F5),
                  Ops.add(Ops.add(" ", Label.DeleteButton), " ")
                )
              )
            )
          ),
          "caption"         => Ops.add(
            Ops.add(@sudo_caption, ": "),
            _("Command Aliases")
          ),
          "tree_item_label" => _("Command Aliases"),
          "widget_names"    => ["CommandAliases"]
        }
      }
    end

    def CreateItems(aliases)
      aliases = deep_copy(aliases)
      items = []
      i = 0

      Builtins.foreach(aliases) do |ent|
        items = Builtins.add(
          items,
          Item(
            Id(i),
            Ops.get_string(ent, "name", ""),
            Builtins.mergestring(Ops.get_list(ent, "mem", []), ",")
          )
        )
        i = Ops.add(i, 1)
      end

      deep_copy(items)
    end

    def SwapUIItems(idx1, idx2)
      items = Convert.convert(
        UI.QueryWidget(Id("table_user_spec"), :Items),
        :from => "any",
        :to   => "list <term>"
      )
      args1 = Builtins.argsof(Ops.get(items, idx1, term(:none)))
      args2 = Builtins.argsof(Ops.get(items, idx2, term(:none)))

      Ops.set(
        items,
        idx1,
        Builtins.toterm(
          :item,
          Builtins.merge([Id(idx1)], Builtins.sublist(args2, 1))
        )
      )
      Ops.set(
        items,
        idx2,
        Builtins.toterm(
          :item,
          Builtins.merge([Id(idx2)], Builtins.sublist(args1, 1))
        )
      )

      UI.ChangeWidget(Id("table_user_spec"), :Items, items)

      nil
    end

    def SwapItems(idx1, idx2)
      item1 = Sudo.GetRule(idx1)
      item2 = Sudo.GetRule(idx2)

      Sudo.SetRule(idx2, item1)
      Sudo.SetRule(idx1, item2)

      nil
    end

    def HandleUserSpecs(key, event)
      event = deep_copy(event)
      ret = Ops.get(event, "ID")

      if ret == "add_spec"
        Sudo.SetItem(Builtins.size(Sudo.GetRules))
        return :add_spec
      elsif ret == "edit_spec"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_user_spec"), :CurrentItem)
        )
        Sudo.SetItem(idx)
        return :edit_spec if Sudo.SystemRulePopup(Sudo.GetRule(idx), false)
      elsif ret == "delete_spec"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_user_spec"), :CurrentItem)
        )
        items = Convert.convert(
          UI.QueryWidget(Id("table_user_spec"), :Items),
          :from => "any",
          :to   => "list <term>"
        )

        if Sudo.SystemRulePopup(Sudo.GetRule(idx), true)
          Sudo.RemoveRule(idx)
          items = Builtins.remove(items, idx)

          i = 0
          items = Builtins.maplist(items) do |tmp|
            args = Builtins.argsof(tmp)
            t = Builtins.toterm(
              :item,
              Builtins.merge([Id(i)], Builtins.sublist(args, 1))
            )
            i = Ops.add(i, 1)
            deep_copy(t)
          end
          UI.ChangeWidget(Id("table_user_spec"), :Items, items)
          Sudo.SetModified
        end
        EnableDisableButtons("edit_spec", "delete_spec", items)
      elsif ret == "up"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_user_spec"), :CurrentItem)
        )
        if idx != 0
          SwapItems(idx, Ops.subtract(idx, 1))
          SwapUIItems(idx, Ops.subtract(idx, 1))
          UI.ChangeWidget(
            Id("table_user_spec"),
            :CurrentItem,
            Ops.subtract(idx, 1)
          )
          Sudo.SetModified
        end
      elsif ret == "down"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_user_spec"), :CurrentItem)
        )
        if idx != Ops.subtract(Builtins.size(Sudo.GetRules), 1)
          SwapItems(idx, Ops.add(idx, 1))
          SwapUIItems(idx, Ops.add(idx, 1))
          UI.ChangeWidget(Id("table_user_spec"), :CurrentItem, Ops.add(idx, 1))
          Sudo.SetModified
        end
      end

      nil
    end

    def InitUserSpecs(key)
      items = []
      rules = Sudo.GetRules
      idx = 0

      Builtins.foreach(rules) do |ent|
        cmds = ""
        if Ops.greater_than(Builtins.size(Ops.get_list(ent, "commands", [])), 1)
          cmds = Builtins.mergestring(Ops.get_list(ent, "commands", []), ",")
        else
          cmds = Ops.get(Ops.get_list(ent, "commands", []), 0, "")
        end
        items = Builtins.add(
          items,
          Item(
            Id(idx),
            Ops.get_string(ent, "user", ""),
            Ops.get_string(ent, "host", ""),
            Ops.get_string(ent, "run_as", ""),
            Ops.get_string(ent, "tag", "") == "NOPASSWD:" ? _("Yes") : _("No"),
            cmds
          )
        )
        idx = Ops.add(idx, 1)
      end

      UI.ChangeWidget(Id("table_user_spec"), :Items, items)
      EnableDisableButtons("edit_spec", "delete_spec", items)

      nil
    end

    def HandleHostAliases(key, event)
      event = deep_copy(event)
      ret = Ops.get(event, "ID")

      if ret == "add_host_alias"
        Sudo.SetItem(Builtins.size(Sudo.GetHostAliases2))
        #current_alias_name = "";
        return :add_h_alias
      elsif ret == "edit_host_alias"
        Sudo.SetItem(
          Convert.to_integer(
            UI.QueryWidget(Id("table_host_aliases"), :CurrentItem)
          )
        )
        return :edit_h_alias
      elsif ret == "delete_host_alias"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_host_aliases"), :CurrentItem)
        )
        items = Convert.convert(
          UI.QueryWidget(Id("table_host_aliases"), :Items),
          :from => "any",
          :to   => "list <term>"
        )
        name = Ops.get_string(Sudo.GetHostAliases2, [idx, "name"], "")

        confirm_delete = true

        if Sudo.SearchRules("host", name)
          if !Popup.ContinueCancel(
              Builtins.sformat(
                _(
                  "Host alias %1 is being used in one of the sudo rules.\nDeleting it may result in an inconsistent sudo configuration file. Really delete it?\n"
                ),
                name
              )
            )
            confirm_delete = false
          end
        end

        if confirm_delete
          Sudo.RemoveHostAlias2(idx)
          items = CreateItems(Sudo.GetHostAliases2)
          UI.ChangeWidget(Id("table_host_aliases"), :Items, items)
          Sudo.SetModified
        end
        EnableDisableButtons("edit_host_alias", "delete_host_alias", items)
      end

      nil
    end

    def InitHostAliases(key)
      aliases = Sudo.GetHostAliases2
      items = CreateItems(aliases)

      UI.ChangeWidget(Id("table_host_aliases"), :Items, items)
      EnableDisableButtons("edit_host_alias", "delete_host_alias", items)

      nil
    end

    def HandleUserAliases(key, event)
      event = deep_copy(event)
      ret = Ops.get(event, "ID")

      if ret == "add_user_alias"
        # No alias name set so far
        Sudo.SetItem(Builtins.size(Sudo.GetUserAliases2))
        return :add_u_alias
      elsif ret == "edit_user_alias"
        Sudo.SetItem(
          Convert.to_integer(
            UI.QueryWidget(Id("table_user_aliases"), :CurrentItem)
          )
        )
        return :edit_u_alias
      elsif ret == "delete_user_alias"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_user_aliases"), :CurrentItem)
        )
        items = Convert.convert(
          UI.QueryWidget(Id("table_user_aliases"), :Items),
          :from => "any",
          :to   => "list <term>"
        )
        name = Ops.get_string(Sudo.GetUserAliases2, [idx, "name"], "")

        confirm_delete = true

        if Sudo.SearchRules("user", name)
          if !Popup.ContinueCancel(
              Builtins.sformat(
                _(
                  "User alias %1 is being used in one of the sudo rules.\nDeleting it may result in an inconsistent sudo configuration file. Really delete it?\n"
                ),
                name
              )
            )
            confirm_delete = false
          end
        end

        if confirm_delete
          Sudo.RemoveUserAlias2(idx)
          items = CreateItems(Sudo.GetUserAliases2)
          UI.ChangeWidget(Id("table_user_aliases"), :Items, items)
          Sudo.SetModified
        end
        EnableDisableButtons("edit_user_alias", "delete_user_alias", items)
      end

      nil
    end

    def InitUserAliases(key)
      aliases = Sudo.GetUserAliases2
      items = CreateItems(aliases)

      UI.ChangeWidget(Id("table_user_aliases"), :Items, items)
      EnableDisableButtons("edit_user_alias", "delete_user_alias", items)

      nil
    end

    def HandleRunAsAliases(key, event)
      event = deep_copy(event)
      ret = Ops.get(event, "ID")

      if ret == "add_runas_alias"
        # No alias name set so far
        Sudo.SetItem(Builtins.size(Sudo.GetRunAsAliases2))
        return :add_r_alias
      elsif ret == "edit_runas_alias"
        Sudo.SetItem(
          Convert.to_integer(
            UI.QueryWidget(Id("table_runas_aliases"), :CurrentItem)
          )
        )
        return :edit_r_alias
      elsif ret == "delete_runas_alias"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_runas_aliases"), :CurrentItem)
        )
        items = Convert.convert(
          UI.QueryWidget(Id("table_runas_aliases"), :Items),
          :from => "any",
          :to   => "list <term>"
        )
        name = Ops.get_string(Sudo.GetRunAsAliases2, [idx, "name"], "")

        confirm_delete = true

        if Sudo.SearchRules("run_as", Ops.add(Ops.add("(", name), ")"))
          if !Popup.ContinueCancel(
              Builtins.sformat(
                _(
                  "RunAs alias %1 is being used in one of the sudo rules.\nDeleting it may result in an inconsistent sudo configuration file. Really delete it?\n"
                ),
                name
              )
            )
            confirm_delete = false
          end
        end

        if confirm_delete
          Sudo.RemoveRunAsAlias2(idx)
          items = CreateItems(Sudo.GetRunAsAliases2)
          UI.ChangeWidget(Id("table_runas_aliases"), :Items, items)
          Sudo.SetModified
        end
        EnableDisableButtons("edit_runas_alias", "delete_runas_alias", items)
      end

      nil
    end

    def InitRunAsAliases(key)
      aliases = Sudo.GetRunAsAliases2
      items = CreateItems(aliases)

      UI.ChangeWidget(Id("table_runas_aliases"), :Items, items)
      EnableDisableButtons("edit_runas_alias", "delete_runas_alias", items)

      nil
    end

    def HandleCmndAliases(key, event)
      event = deep_copy(event)
      ret = Ops.get(event, "ID")

      if ret == "add_command_alias"
        # No alias name set so far
        Sudo.SetItem(Builtins.size(Sudo.GetCmndAliases2))
        return :add_c_alias
      elsif ret == "edit_command_alias"
        Sudo.SetItem(
          Convert.to_integer(
            UI.QueryWidget(Id("table_command_aliases"), :CurrentItem)
          )
        )
        return :edit_c_alias
      elsif ret == "delete_command_alias"
        idx = Convert.to_integer(
          UI.QueryWidget(Id("table_command_aliases"), :CurrentItem)
        )
        items = Convert.convert(
          UI.QueryWidget(Id("table_command_aliases"), :Items),
          :from => "any",
          :to   => "list <term>"
        )
        name = Ops.get_string(Sudo.GetCmndAliases2, [idx, "name"], "")
        confirm_delete = true

        if Sudo.SearchRules("commands", name)
          if !Popup.ContinueCancel(
              Builtins.sformat(
                _(
                  "Command alias %1 is being used in one of the sudo rules.\nDeleting it may result in an inconsistent sudo configuration file. Really delete it?\n"
                ),
                name
              )
            )
            confirm_delete = false
          end
        end

        if confirm_delete
          Sudo.RemoveCmndAlias2(idx)
          items = CreateItems(Sudo.GetCmndAliases2)
          UI.ChangeWidget(Id("table_command_aliases"), :Items, items)
          Sudo.SetModified
        end
        EnableDisableButtons(
          "edit_command_alias",
          "delete_command_alias",
          items
        )
      end

      nil
    end

    def InitCmndAliases(key)
      aliases = Sudo.GetCmndAliases2
      items = CreateItems(aliases)

      UI.ChangeWidget(Id("table_command_aliases"), :Items, items)
      EnableDisableButtons("edit_command_alias", "delete_command_alias", items)

      nil
    end

    def RunSudoDialogs
      tree_dialogs = [
        "user_specs",
        "user_aliases",
        "runas_aliases",
        "host_aliases",
        "cmnd_aliases"
      ]


      DialogTree.ShowAndRun(
        {
          "ids_order"      => tree_dialogs,
          "initial_screen" => @initial_screen,
          "screens"        => @tabs,
          "widget_descr"   => @widgets_handling,
          "back_button"    => nil, #Label::BackButton(),
          "abort_button"   => Label.CancelButton,
          "next_button"    => Label.OKButton,
          "functions"      => @functions
        }
      )
    end
  end
end
