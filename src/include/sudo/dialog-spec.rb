# encoding: utf-8

module Yast
  module SudoDialogSpecInclude
    def initialize_sudo_dialog_spec(include_target)
      Yast.import "UI"

      textdomain "sudo"

      Yast.import "Wizard"
      Yast.import "Sudo"
      Yast.import "Label"
      Yast.import "Popup"

      Yast.include include_target, "sudo/helps.rb"
      Yast.include include_target, "sudo/complex.rb"
    end

    def RedrawCmndTable(commands)
      commands = deep_copy(commands)
      items = UpdateCmdList(commands)

      UI.ChangeWidget(Id("commands"), :Items, items)
      EnableDisableButtons("command_edit", "command_remove", items)

      nil
    end


    def AddEditUserSpecDialog(what)
      caption = ""
      spec = {}
      commands = []
      users = Convert.convert(
        Builtins.merge(Sudo.all_users, Sudo.GetAliasNames("user")),
        :from => "list",
        :to   => "list <string>"
      )
      hosts = Builtins.prepend(Sudo.GetAliasNames("host"), "ALL")
      run_as = Convert.convert(
        Builtins.merge(Sudo.all_users, Sudo.GetAliasNames("run_as")),
        :from => "list",
        :to   => "list <string>"
      )

      if what == "Add"
        caption = _("New Sudo Rule") 
        #Setting default values
      elsif what == "Edit"
        caption = _("Existing Sudo Rule ")
        spec = Sudo.GetRule(Sudo.GetItem)
        commands = Ops.get_list(spec, "commands", [])
      end

      contents = VBox(
        Left(
          ComboBox(
            Id("user_name"),
            Opt(:editable),
            _("User, Group or User Alias"),
            Builtins.sort(users) { |s, t| Ops.less_than(s, t) }
          )
        ),
        Left(
          ComboBox(
            Id("host_name"),
            Opt(:editable),
            _("Host or Host Alias"),
            Builtins.sort(hosts) { |s, t| Ops.less_than(s, t) }
          )
        ),
        Left(
          ComboBox(
            Id("run_as"),
            Opt(:editable),
            _("RunAs or RunAs Alias"),
            Builtins.sort(run_as) { |s, t| Ops.less_than(s, t) }
          )
        ),
        Left(CheckBox(Id("no_passwd"), _("No Password"))),
        Left(Label(_("Commands to Run"))),
        Table(Id("commands"), Header(_("Command"), _("Parameters")), []),
        Left(
          HBox(
            PushButton(
              Id("command_add"),
              Opt(:key_F3),
              Ops.add(Ops.add(" ", Label.AddButton), " ")
            ),
            PushButton(
              Id("command_edit"),
              Opt(:key_F4),
              Ops.add(Ops.add(" ", Label.EditButton), " ")
            ),
            PushButton(
              Id("command_remove"),
              Opt(:key_F5),
              Ops.add(Ops.add(" ", Label.DeleteButton), " ")
            )
          )
        )
      )

      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "spec_single", ""),
        Label.CancelButton,
        Label.OKButton
      )
      Wizard.HideAbortButton
      UI.ChangeWidget(Id("user_name"), :ValidChars, Sudo.ValidCharsUsername)
      UI.ChangeWidget(Id("run_as"), :ValidChars, Sudo.ValidCharsUsername)

      #initialize UI
      UI.ChangeWidget(Id("user_name"), :Value, Ops.get_string(spec, "user", ""))
      UI.ChangeWidget(Id("host_name"), :Value, Ops.get_string(spec, "host", ""))
      UI.ChangeWidget(
        Id("run_as"),
        :Value,
        Builtins.deletechars(Ops.get_string(spec, "run_as", ""), "()")
      )
      UI.ChangeWidget(
        Id("no_passwd"),
        :Value,
        Ops.get_string(spec, "tag", "") == "NOPASSWD:"
      )
      RedrawCmndTable(commands)


      ret = nil
      while true
        ret = UI.UserInput
        # next
        if ret == :next
          Ops.set(spec, "user", UI.QueryWidget(Id("user_name"), :Value))
          Ops.set(spec, "host", UI.QueryWidget(Id("host_name"), :Value))
          Ops.set(
            spec,
            "run_as",
            Convert.to_string(UI.QueryWidget(Id("run_as"), :Value))
          )
          Ops.set(spec, "commands", commands)

          if Convert.to_boolean(UI.QueryWidget(Id("no_passwd"), :Value))
            Ops.set(spec, "tag", "NOPASSWD:")
          else
            Ops.set(spec, "tag", "")
          end

          if Ops.get_string(spec, "user", "") == ""
            Popup.Error(_("Username must not be empty."))
            UI.SetFocus(Id("user_name"))
            next
          end
          if Ops.get_string(spec, "host", "") == ""
            Popup.Error(_("Hostname must not be empty."))
            UI.SetFocus(Id("host_name"))
            next
          end
          if !ValidateHost(Ops.get_string(spec, "host", ""))
            UI.SetFocus(Id("host_name"))
            next
          end
          if Ops.get_list(spec, "commands", []) == []
            Popup.Error(_("Command list must have at least one entry."))
            UI.SetFocus(Id("commands"))
            next
          end
          if Ops.get_string(spec, "run_as", "") != ""
            Ops.set(
              spec,
              "run_as",
              Ops.add(Ops.add("(", Ops.get_string(spec, "run_as", "")), ")")
            )
          end
          Sudo.SetRule(Sudo.GetItem, spec)
          Sudo.SetModified
          break 
          # back
        elsif ret == :back
          break 
          # add command
        elsif ret == "command_add"
          new_command = AddCommandDialog("", "")

          if new_command != "" && !Builtins.contains(commands, new_command)
            Builtins.y2milestone("%1", new_command)
            commands = Builtins.add(commands, new_command)
            RedrawCmndTable(commands)
          end 
          # edit command
        elsif ret == "command_edit"
          current_item = Convert.to_integer(
            UI.QueryWidget(Id("commands"), :CurrentItem)
          )
          it = Convert.to_term(
            UI.QueryWidget(Id("commands"), term(:Item, current_item))
          )

          new_command = AddCommandDialog(
            Ops.get_string(it, 1, ""),
            Ops.get_string(it, 2, "")
          )
          if new_command != ""
            Ops.set(commands, current_item, new_command)
            RedrawCmndTable(commands)
          end 

          # remove command
        elsif ret == "command_remove"
          current_item = Convert.to_integer(
            UI.QueryWidget(Id("commands"), :CurrentItem)
          )

          commands = Builtins.remove(commands, current_item)
          RedrawCmndTable(commands)
        else
          Builtins.y2error("unexpected retcode: %1", ret)
          next
        end
      end

      @initial_screen = "user_specs"
      Wizard.RestoreNextButton
      deep_copy(ret)
    end

    def SaveUserSpec
      :next
    end
  end
end
