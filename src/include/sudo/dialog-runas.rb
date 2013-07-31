# encoding: utf-8

module Yast
  module SudoDialogRunasInclude
    def initialize_sudo_dialog_runas(include_target)
      Yast.import "UI"
      textdomain "sudo"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Sudo"
      Yast.import "Report"

      Yast.include include_target, "sudo/complex.rb"
      Yast.include include_target, "sudo/helps.rb"
    end

    def RedrawRunAsAlias(members)
      members = deep_copy(members)
      items = []

      Builtins.foreach(members) do |it|
        items = Builtins.add(items, Item(Id(it), it))
      end

      UI.ChangeWidget(Id("runas_alias_members"), :Items, items)
      UI.ChangeWidget(Id("remove_member"), :Enabled, items != [])

      nil
    end

    def AddEditRunAsAliasDialog(what)
      caption = ""
      ra = Sudo.GetRunAsAliases2
      it = Ops.get(ra, Sudo.GetItem, {})

      alias_members = []
      name = ""
      items = []
      users = Convert.convert(
        Builtins.merge(Sudo.all_users, Sudo.GetAliasNames("run_as")),
        :from => "list",
        :to   => "list <string>"
      )

      if what == "Add"
        caption = _("New RunAs Alias")
      elsif what == "Edit"
        alias_members = Ops.get_list(it, "mem", [])
        name = Ops.get_string(it, "name", "")
        Builtins.foreach(alias_members) do |member|
          users = Builtins.filter(users) { |user| user != member }
        end
        caption = _("Existing RunAs Alias")
      end

      contents = VBox(
        Left(InputField(Id("runas_alias_name"), _("Alias Name (in CAPITALS)"))),
        VSpacing(1),
        VBox(
          Table(
            Id("runas_alias_members"),
            Opt(:hstretch, :vstretch),
            Header(_("Alias Members")),
            []
          ),
          HBox(
            PushButton(
              Id("add_member"),
              Opt(:key_F3),
              Ops.add(Ops.add(" ", Label.AddButton), " ")
            ),
            PushButton(
              Id("remove_member"),
              Opt(:key_F5),
              Ops.add(Ops.add(" ", Label.DeleteButton), " ")
            ),
            HStretch()
          )
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "runas_alias", ""),
        Label.CancelButton,
        Label.OKButton
      )
      Wizard.HideAbortButton
      UI.ChangeWidget(
        Id("runas_alias_name"),
        :ValidChars,
        "_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      )
      UI.ChangeWidget(Id("runas_alias_name"), :Value, name)

      RedrawRunAsAlias(alias_members)

      ret = nil
      while true
        ret = UI.UserInput
        # next
        if ret == :next
          new_alias = Builtins.toupper(
            Convert.to_string(UI.QueryWidget(Id("runas_alias_name"), :Value))
          )
          if new_alias == ""
            Popup.Error(_("Alias name must not be empty."))
            UI.SetFocus(Id("runas_alias_name"))
            next
          end
          if name != new_alias
            if Sudo.SearchAlias2(new_alias, Sudo.GetRunAsAliases2)
              Popup.Error(
                Builtins.sformat(
                  _("Alias with name %1 already exists"),
                  new_alias
                )
              )
              UI.SetFocus(Id("runas_alias_name"))
              next
            end
          end
          if alias_members == []
            Popup.Error(_("Alias must have at least one member."))
            UI.SetFocus(Id("runas_alias_members"))
            next
          end

          Ops.set(it, "name", new_alias)
          Ops.set(it, "mem", alias_members)
          Sudo.SetRunAsAlias(Sudo.GetItem, it)
          Sudo.SetModified
          break 
          # back
        elsif ret == :back
          break 
          # add users
        elsif ret == "add_member"
          new_member = AddUserDialog(users)

          if new_member != ""
            alias_members = Builtins.add(alias_members, new_member)
            users = Builtins.filter(users) { |s| s != new_member }
            RedrawRunAsAlias(alias_members)
          end 
          # delete users
        elsif ret == "remove_member"
          current_item = Convert.to_string(
            UI.QueryWidget(Id("runas_alias_members"), :CurrentItem)
          )
          alias_members = Builtins.filter(alias_members) do |s|
            s != current_item
          end
          users = Builtins.add(users, current_item)
          RedrawRunAsAlias(alias_members) 
          # unknown
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      @initial_screen = "runas_aliases"
      Wizard.RestoreNextButton
      deep_copy(ret)
    end

    def SaveRunAsAliases
      :next
    end
  end
end
