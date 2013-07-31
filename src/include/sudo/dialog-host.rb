# encoding: utf-8

module Yast
  module SudoDialogHostInclude
    def initialize_sudo_dialog_host(include_target)
      Yast.import "UI"
      textdomain "sudo"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Sudo"
      Yast.import "Report"

      Yast.include include_target, "sudo/complex.rb"
      Yast.include include_target, "sudo/helps.rb"
    end

    def RedrawHostAlias(name, members)
      members = deep_copy(members)
      items = []

      UI.ChangeWidget(Id("host_alias_name"), :Value, name) if name != ""

      Builtins.foreach(members) do |it|
        items = Builtins.add(items, Item(Id(it), it))
      end

      UI.ChangeWidget(Id("host_alias_members"), :Items, items)
      EnableDisableButtons("edit_host", "remove_host", items)

      nil
    end

    def AddEditHostAliasDialog(what)
      caption = ""
      ha = Sudo.GetHostAliases2
      it = Ops.get(ha, Sudo.GetItem, {})

      alias_members = []
      name = ""
      items = []

      if what == "Add"
        caption = _("New Host Alias")
      elsif what == "Edit"
        alias_members = Ops.get_list(it, "mem", [])
        name = Ops.get_string(it, "name", "")
        caption = _("Existing Host Alias")
      end

      contents = VBox(
        Left(InputField(Id("host_alias_name"), _("Alias Name (in CAPITALS)"))),
        Left(Label(_("Hostnames or Networks in the Alias"))),
        Table(Id("host_alias_members"), Header(_("Hostnames/Networks")), []),
        Left(
          HBox(
            PushButton(
              Id("add_host"),
              Opt(:key_F3),
              Ops.add(Ops.add(" ", Label.AddButton), " ")
            ),
            PushButton(
              Id("edit_host"),
              Opt(:key_F4),
              Ops.add(Ops.add(" ", Label.EditButton), " ")
            ),
            PushButton(
              Id("remove_host"),
              Opt(:key_F5),
              Ops.add(Ops.add(" ", Label.DeleteButton), " ")
            )
          )
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "host_alias", ""),
        Label.CancelButton,
        Label.OKButton
      )
      Wizard.HideAbortButton
      UI.ChangeWidget(
        Id("host_alias_name"),
        :ValidChars,
        "_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      )

      RedrawHostAlias(name, alias_members)

      ret = nil
      while true
        ret = UI.UserInput
        # next
        if ret == :next
          new_alias = Builtins.toupper(
            Convert.to_string(UI.QueryWidget(Id("host_alias_name"), :Value))
          )

          if new_alias == ""
            Popup.Error(_("Alias name must not be empty."))
            UI.SetFocus(Id("host_alias_name"))
            next
          end
          if name != new_alias
            if Sudo.SearchAlias2(new_alias, Sudo.GetHostAliases2)
              Popup.Error(
                Builtins.sformat(
                  _("Alias with name %1 already exists"),
                  new_alias
                )
              )
              UI.SetFocus(Id("host_alias_name"))
              next
            end 

            #Sudo::RemoveHostAlias(current_alias_name);
          end
          if alias_members == []
            Popup.Error(_("Alias must have at least one member."))
            UI.SetFocus(Id("host_alias_members"))
            next
          end

          Ops.set(it, "name", new_alias)
          Ops.set(it, "mem", alias_members)
          Sudo.SetHostAlias(Sudo.GetItem, it)
          Sudo.SetModified
          break 

          # back
        elsif ret == :back
          break 
          # unknown
        elsif ret == "add_host"
          new_member = AddHostDialog("")

          if new_member != ""
            alias_members = Builtins.add(alias_members, new_member)
            RedrawHostAlias("", alias_members)
          end 
          # edit hosts
        elsif ret == "edit_host"
          current_item = Convert.to_string(
            UI.QueryWidget(Id("host_alias_members"), :CurrentItem)
          )
          new_member = AddHostDialog(current_item)

          if current_item != new_member
            alias_members = Builtins.filter(alias_members) do |s|
              s != current_item
            end
            alias_members = Builtins.add(alias_members, new_member)
            RedrawHostAlias("", alias_members)
          end 
          # delete hosts
        elsif ret == "remove_host"
          current_item = Convert.to_string(
            UI.QueryWidget(Id("host_alias_members"), :CurrentItem)
          )

          alias_members = Builtins.filter(alias_members) do |s|
            s != current_item
          end
          RedrawHostAlias("", alias_members) 
          # unknown
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      @initial_screen = "host_aliases"
      Wizard.RestoreNextButton
      deep_copy(ret)
    end

    def SaveHostAliases
      :next
    end
  end
end
