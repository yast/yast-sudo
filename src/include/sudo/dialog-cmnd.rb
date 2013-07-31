# encoding: utf-8

module Yast
  module SudoDialogCmndInclude
    def initialize_sudo_dialog_cmnd(include_target)
      Yast.import "UI"
      textdomain "sudo"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Sudo"
      Yast.import "Report"

      Yast.include include_target, "sudo/complex.rb"
      Yast.include include_target, "sudo/helps.rb"
    end

    def RedrawCmndAlias(name, members)
      members = deep_copy(members)
      items = UpdateCmdList(members)

      UI.ChangeWidget(Id("cmnd_alias_name"), :Value, name) if name != ""

      UI.ChangeWidget(Id("cmnd_alias_members"), :Items, items)
      EnableDisableButtons("edit_command", "remove_command", items)

      nil
    end

    def AddEditCmndAliasDialog(what)
      caption = ""
      ca = Sudo.GetCmndAliases2
      it = Ops.get(ca, Sudo.GetItem, {})

      alias_members = []
      name = ""
      items = []

      if what == "Add"
        caption = _("New Command Alias")
      elsif what == "Edit"
        alias_members = Ops.get_list(it, "mem", [])
        name = Ops.get_string(it, "name", "")
        caption = _("Existing Command Alias")
      end

      contents = VBox(
        Left(InputField(Id("cmnd_alias_name"), _("Alias Name (in CAPITALS)"))),
        Left(Label(_("Command Names or Directories in the Alias"))),
        Table(
          Id("cmnd_alias_members"),
          Header(_("Command"), _("Parameters")),
          []
        ),
        Left(
          HBox(
            PushButton(
              Id("add_command"),
              Opt(:key_F3),
              Ops.add(Ops.add(" ", Label.AddButton), " ")
            ),
            PushButton(
              Id("edit_command"),
              Opt(:key_F4),
              Ops.add(Ops.add(" ", Label.EditButton), " ")
            ),
            PushButton(
              Id("remove_command"),
              Opt(:key_F5),
              Ops.add(Ops.add(" ", Label.DeleteButton), " ")
            )
          )
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "command_alias", ""),
        Label.CancelButton,
        Label.OKButton
      )
      Wizard.HideAbortButton
      UI.ChangeWidget(
        Id("cmnd_alias_name"),
        :ValidChars,
        "_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      )

      RedrawCmndAlias(name, alias_members)

      ret = nil
      while true
        ret = UI.UserInput
        # next
        if ret == :next
          new_alias = Builtins.toupper(
            Convert.to_string(UI.QueryWidget(Id("cmnd_alias_name"), :Value))
          )
          if new_alias == ""
            Popup.Error(_("Alias name must not be empty."))
            UI.SetFocus(Id("cmnd_alias_name"))
            next
          end
          if name != new_alias
            if Sudo.SearchAlias2(new_alias, Sudo.GetCmndAliases2)
              Popup.Error(
                Builtins.sformat(
                  _("Alias with name %1 already exists"),
                  new_alias
                )
              )
              UI.SetFocus(Id("cmnd_alias_name"))
              next
            end
          end
          if alias_members == []
            Popup.Error(_("Alias must have at least one member."))
            UI.SetFocus(Id("cmnd_alias_members"))
            next
          end

          Ops.set(it, "name", new_alias)
          Ops.set(it, "mem", alias_members)
          Sudo.SetCmndAlias(Sudo.GetItem, it)
          Sudo.SetModified
          break 

          # back
        elsif ret == :back
          break 
          # unknown
        elsif ret == "add_command"
          new_member = AddCommandDialog("", "")

          if new_member != "" && !Builtins.contains(alias_members, new_member)
            alias_members = Builtins.add(alias_members, new_member)
            RedrawCmndAlias("", alias_members)
          end 
          # edit command
        elsif ret == "edit_command"
          current_item = Convert.to_integer(
            UI.QueryWidget(Id("cmnd_alias_members"), :CurrentItem)
          )
          it2 = Convert.to_term(
            UI.QueryWidget(Id("cmnd_alias_members"), term(:Item, current_item))
          )

          new_member = AddCommandDialog(
            Ops.get_string(it2, 1, ""),
            Ops.get_string(it2, 2, "")
          )
          Ops.set(alias_members, current_item, new_member)
          RedrawCmndAlias("", alias_members) 

          # delete commands
        elsif ret == "remove_command"
          current_item = Convert.to_integer(
            UI.QueryWidget(Id("cmnd_alias_members"), :CurrentItem)
          )

          alias_members = Builtins.remove(alias_members, current_item)
          RedrawCmndAlias("", alias_members) 
          # unknown
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      @initial_screen = "cmnd_aliases"
      Wizard.RestoreNextButton
      deep_copy(ret)
    end

    def SaveCommandAliases
      :next
    end
  end
end
