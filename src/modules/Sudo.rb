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

# File:	modules/Sudo.ycp
# Package:	Configuration of sudo
# Summary:	Sudo settings, input and output functions
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: Sudo.ycp 27914 2006-02-13 14:32:08Z locilka $
#
# Representation of the configuration of sudo.
# Input and output routines.
require "yast"

module Yast

  class UnsupportedSudoConfig < RuntimeError
    attr_reader :line

    def initialize(msg, line)
      super(msg)

      @line = line
    end
  end

  class SudoClass < Module
    def main
      Yast.import "UI"
      textdomain "sudo"

      Yast.import "Confirm"
      Yast.import "Map"
      Yast.import "Message"
      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Popup"
      Yast.import "Service"
      Yast.import "String"
      Yast.import "Summary"
      Yast.import "UsersPasswd"

      # Data was modified?
      @modified = false

      @sl = 10

      @ValidCharsUsername = Ops.add(
        Builtins.deletechars(String.CGraph, "'\""),
        " "
      )

      @settings2 = []
      @host_aliases2 = []
      @user_aliases2 = []
      @cmnd_aliases2 = []
      @runas_aliases2 = []
      @defaults = []
      @rules = []
      @all_users = []

      @citem = -1
    end

    # Data was modified?
    # @return true if modified
    def GetModified
      @modified
    end

    def SetModified
      @modified = true

      nil
    end

    def ReadSudoSettings2
      @settings2 = Convert.convert(
        SCR.Read(path(".sudo")),
        :from => "any",
        :to   => "list <list>"
      )
      Builtins.y2milestone("Sudo settings %1", @settings2)

      Builtins.foreach(@settings2) do |line|
        type = Ops.get_string(line, 1, "")
        case type
          when "Host_Alias"
            lst = Builtins.splitstring(
              Builtins.deletechars(Ops.get_string(line, 3, ""), " \t"),
              ","
            )
            @host_aliases2 = Builtins.add(
              @host_aliases2,
              {
                "c"    => Ops.get_string(line, 0, ""),
                "name" => Ops.get_string(line, 2, ""),
                "mem"  => lst
              }
            )
          when "User_Alias"
            lst = Builtins.splitstring(
              Builtins.deletechars(Ops.get_string(line, 3, ""), " \t"),
              ","
            )
            @user_aliases2 = Builtins.add(
              @user_aliases2,
              {
                "c"    => Ops.get_string(line, 0, ""),
                "name" => Ops.get_string(line, 2, ""),
                "mem"  => lst
              }
            )
          when "Cmnd_Alias"
            lst = Builtins.maplist(
              Builtins.splitstring(Ops.get_string(line, 3, ""), ",")
            ) do |s|
              Builtins.substring(s, Builtins.findfirstnotof(s, " \t"))
            end
            @cmnd_aliases2 = Builtins.add(
              @cmnd_aliases2,
              {
                "c"    => Ops.get_string(line, 0, ""),
                "name" => Ops.get_string(line, 2, ""),
                "mem"  => lst
              }
            )
          when "Runas_Alias"
            lst = Builtins.splitstring(
              Builtins.deletechars(Ops.get_string(line, 3, ""), " \t"),
              ","
            )
            @runas_aliases2 = Builtins.add(
              @runas_aliases2,
              {
                "c"    => Ops.get_string(line, 0, ""),
                "name" => Ops.get_string(line, 2, ""),
                "mem"  => lst
              }
            )
          else
            if Builtins.regexpmatch(type, "^Defaults.*$")
              #do nothing, keep defaults untouched
              @defaults = Builtins.add(@defaults, line)
            else
              m = {}
              cmd = []

              if Builtins.regexpmatch(type, "^.*\\\\.*$")
                type = Builtins.regexpsub(type, "^(.*)\\\\(.*)$", "\\1\\2")
              end
              Ops.set(m, "user", type)

              Ops.set(m, "host", Ops.get_string(line, 2, ""))

              #match "(.*)"
              if Builtins.regexpmatch(Ops.get_string(line, 3, ""), "\\(.*\\)")
                Ops.set(
                  m,
                  "run_as",
                  Builtins.regexpsub(
                    Ops.get_string(line, 3, ""),
                    "(\\(.*\\))",
                    "\\1"
                  )
                )
              end
              if Builtins.regexpmatch(
                  Ops.get_string(line, 3, ""),
                  "NOPASSWD:|SETENV:|NOEXEC:"
                )
                rest = Ops.get_string(line, 3, "")
                # remove from rest runas as it can also contain ":"
                if rest.gsub(/\([^\)]*\)/, "").count(":") > 1
                  raise UnsupportedSudoConfig.new(
                    _("Multiple tags on single line are not supported."),
                    "#{type} #{m["host"]} = #{Ops.get_string(line, 3, "")}"
                  )
                end
                Ops.set(
                  m,
                  "tag",
                  Builtins.regexpsub(
                    Ops.get_string(line, 3, ""),
                    "(NOPASSWD:|SETENV:|NOEXEC:)",
                    "\\1"
                  )
                )
              end

              # if(issubstring(line[3]:"","NOPASSWD:")) {
              # 	m["no_passwd"] = (boolean) true;
              # }
              # else {
              #      m["no_passwd"] = (boolean) false;
              # }

              cmd = Builtins.splitstring(Ops.get_string(line, 3, ""), "):")
              Ops.set(
                m,
                "commands",
                Builtins.splitstring(
                  Ops.get(cmd, Ops.subtract(Builtins.size(cmd), 1), ""),
                  ","
                )
              )
              Ops.set(
                m,
                "commands",
                Builtins.maplist(Ops.get_list(m, "commands", [])) do |s|
                  Builtins.substring(s, Builtins.findfirstnotof(s, " \t"))
                end
              )
              Ops.set(m, "comment", Ops.get_string(line, 0, ""))

              @rules = Builtins.add(@rules, m)
            end
        end
      end

      Builtins.y2milestone(
        "user %1 host %2 runas %3 cmnd %4 def %5 rules %6",
        @user_aliases2,
        @host_aliases2,
        @runas_aliases2,
        @cmnd_aliases2,
        @defaults,
        @rules
      )


      true
    end


    def ReadLocalUsers
      return false if !UsersPasswd.Read({})

      users = Convert.convert(
        Builtins.merge(
          Map.Keys(UsersPasswd.GetUsers("local")),
          Map.Keys(UsersPasswd.GetUsers("system"))
        ),
        :from => "list",
        :to   => "list <string>"
      )

      available_groups = Convert.convert(
        Builtins.merge(
          Map.Keys(UsersPasswd.GetGroups("local")),
          Map.Keys(UsersPasswd.GetGroups("system"))
        ),
        :from => "list",
        :to   => "list <string>"
      )

      available_groups = Builtins.maplist(available_groups) do |group|
        Ops.add("%", group)
      end

      @all_users = Convert.convert(
        Builtins.merge(users, available_groups),
        :from => "list",
        :to   => "list <string>"
      )
      Builtins.y2milestone(
        "Read the following users and groups: %1",
        @all_users
      )

      true
    end

    def WriteSudoSettings2
      set = []

      Builtins.foreach(@host_aliases2) do |a|
        line = [
          Ops.get_string(a, "c", ""),
          "Host_Alias",
          Ops.get_string(a, "name", ""),
          Builtins.mergestring(Ops.get_list(a, "mem", []), ",")
        ]
        set = Builtins.add(set, line)
      end
      Builtins.foreach(@user_aliases2) do |a|
        line = [
          Ops.get_string(a, "c", ""),
          "User_Alias",
          Ops.get_string(a, "name", ""),
          Builtins.mergestring(Ops.get_list(a, "mem", []), ",")
        ]
        set = Builtins.add(set, line)
      end
      Builtins.foreach(@cmnd_aliases2) do |a|
        line = [
          Ops.get_string(a, "c", ""),
          "Cmnd_Alias",
          Ops.get_string(a, "name", ""),
          Builtins.mergestring(Ops.get_list(a, "mem", []), ",")
        ]
        set = Builtins.add(set, line)
      end

      set = Convert.convert(
        Builtins.merge(set, @defaults),
        :from => "list",
        :to   => "list <list>"
      )

      Builtins.foreach(@runas_aliases2) do |a|
        line = [
          Ops.get_string(a, "c", ""),
          "Runas_Alias",
          Ops.get_string(a, "name", ""),
          Builtins.mergestring(Ops.get_list(a, "mem", []), ",")
        ]
        set = Builtins.add(set, line)
      end

      Builtins.foreach(@rules) do |m|
        user = Ops.get_string(m, "user", "")
        user = Builtins.mergestring(Builtins.splitstring(user, "\\"), "\\\\")
        host = Ops.get_string(m, "host", "")
        comment = Ops.get_string(m, "comment", "")
        rest = Ops.add(
          Ops.add(
            Ops.add(Ops.get_string(m, "run_as", ""), " "),
            Ops.get_string(m, "tag", "")
          ),
          Builtins.mergestring(Ops.get_list(m, "commands", []), ",")
        )
        set = Builtins.add(set, [comment, user, host, rest])
      end

      Builtins.y2milestone("Sudo settings %1", set)

      SCR.Write(path(".sudo"), set) && SCR.Write(path(".sudo"), nil)
    end

    def SetItem(i)
      Builtins.y2internal("Current item %1", i)
      @citem = i

      nil
    end

    def GetItem
      @citem
    end

    def GetRules
      deep_copy(@rules)
    end

    def RemoveRule(i)
      @rules = Builtins.remove(@rules, i)

      nil
    end

    def GetRule(i)
      Ops.get(@rules, i, {})
    end

    def SetRule(i, spec)
      spec = deep_copy(spec)
      Ops.set(@rules, i, spec)

      nil
    end

    def SearchRules(what, key)
      found = false

      Builtins.foreach(@rules) do |m|
        if Builtins.haskey(m, what)
          if what == "commands"
            if Builtins.contains(Ops.get_list(m, what, []), key)
              found = true
              raise Break
            end
          else
            if Ops.get_string(m, what, "") == key
              found = true
              raise Break
            end
          end
        end
      end

      found
    end

    def SystemRulePopup(m, delete)
      m = deep_copy(m)
      if Ops.get_string(m, "user", "") == "ALL" &&
          Ops.get_string(m, "host", "") == "ALL" &&
          Ops.get_string(m, "run_as", "") == "(ALL)"
        text = _(
          "This rule is a system rule necessary for correct functionality of sudo.\n"
        )

        if delete
          text = Ops.add(
            text,
            _(
              "After deleting it, some applications may no longer work.\nReally delete?"
            )
          )
        else
          text = Ops.add(
            text,
            _(
              "If you change it, some applications may no longer work.\nReally edit? "
            )
          )
        end

        return Popup.YesNo(text)
      else
        return true
      end
    end


    def GetAliasNames(what)
      ret = []
      case what
        when "user"
          ret = Builtins.maplist(@user_aliases2) do |m|
            Ops.get_string(m, "name", "")
          end
        when "run_as"
          ret = Builtins.maplist(@runas_aliases2) do |m|
            Ops.get_string(m, "name", "")
          end
        when "host"
          ret = Builtins.maplist(@host_aliases2) do |m|
            Ops.get_string(m, "name", "")
          end
        when "command"
          ret = Builtins.maplist(@cmnd_aliases2) do |m|
            Ops.get_string(m, "name", "")
          end
        else
          return []
      end
      deep_copy(ret)
    end

    def SearchAlias2(name, aliases)
      aliases = deep_copy(aliases)
      tmp = []
      tmp = Builtins.filter(aliases) do |m|
        Ops.get_string(m, "name", "") == name
      end

      Ops.greater_than(Builtins.size(tmp), 0)
    end


    # Users
    def GetUserAliases2
      deep_copy(@user_aliases2)
    end

    def SetUserAlias(i, _alias)
      _alias = deep_copy(_alias)
      Ops.set(@user_aliases2, i, _alias)

      nil
    end

    def RemoveUserAlias2(i)
      @user_aliases2 = Builtins.remove(@user_aliases2, i)

      nil
    end

    # end Users

    # Hosts
    def GetHostAliases2
      deep_copy(@host_aliases2)
    end

    def RemoveHostAlias2(i)
      @host_aliases2 = Builtins.remove(@host_aliases2, i)

      nil
    end

    def SetHostAlias(i, _alias)
      _alias = deep_copy(_alias)
      Ops.set(@host_aliases2, i, _alias)

      nil
    end
    # end Hosts

    # RunAs
    def GetRunAsAliases2
      deep_copy(@runas_aliases2)
    end

    def RemoveRunAsAlias2(i)
      @runas_aliases2 = Builtins.remove(@runas_aliases2, i)

      nil
    end

    def SetRunAsAlias(i, _alias)
      _alias = deep_copy(_alias)
      Ops.set(@runas_aliases2, i, _alias)

      nil
    end

    # end RunAs

    # Commands
    def GetCmndAliases2
      deep_copy(@cmnd_aliases2)
    end

    def SetCmndAlias(i, _alias)
      _alias = deep_copy(_alias)
      Ops.set(@cmnd_aliases2, i, _alias)

      nil
    end

    def RemoveCmndAlias2(i)
      @cmnd_aliases2 = Builtins.remove(@cmnd_aliases2, i)

      nil
    end

    #end Commands

    def Abort
      if GetModified()
        return Popup.YesNo(
          _(
            "All changes will be lost. Really quit sudo configuration without saving?"
          )
        )
      else
        return true
      end
    end

    #  * Checks whether an Abort button has been pressed.
    #  * If so, calls function to confirm the abort call.
    #  :*
    #  * @return boolean true if abort confirmed
    def PollAbort
      return Abort() if UI.PollInput == :abort

      false
    end

    # Read all sudo settings
    # @return true on success
    def Read
      return false if !Confirm.MustBeRoot

      begin
        Report.Error(Message.CannotReadCurrentSettings) if !ReadSudoSettings2()
      rescue UnsupportedSudoConfig => e
        msg = _("Unsupported configuration found. YaST2 exits now to prevent breaking system.")
        msg += "\n" + _("Issue: ") + e.message
        msg += "\n" + _("Line content: ") + e.line
        Report.Error(msg)

        return false
      end

      # Error message
      if !ReadLocalUsers()
        Report.Error(_("An error occurred while reading users and groups."))
      end

      # Sudo read dialog caption
      # string caption = _("Initializing sudo Configuration");
      #
      # integer steps = 2;
      #
      # Progress::New( caption, " ", steps, [
      # 	    /* Progress stage 1/2
      # 	    _("Read sudo settings"),
      # 	    /* Progress stage 2/2
      # 	    _("Read local users and groups")
      # 	], [
      # 	    /* Progress step 1/2
      # 	    _("Reading sudo settings..."),
      # 	    /* Progress step 2/2
      # 	    _("Reading local users and groups..."),
      # 	    /* Progress finished
      # 	    Message::Finished()
      # 	],
      # 	""
      # );

      @modified = false
      true
    end

    # Write all sudo settings
    # @return true on success
    def Write
      # Sudo read dialog caption
      caption = _("Saving sudo Configuration")

      steps = 1

      sl = 500

      ret = true

      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/1
          _("Write the settings")
        ],
        [
          # Progress step 1/1
          _("Writing the settings..."),
          # Progress finished
          Message.Finished
        ],
        ""
      )

      Builtins.sleep(sl)

      # write settings
      return false if PollAbort()
      Progress.NextStage
      # Error message
      if !WriteSudoSettings2()
        msg = _("Cannot write settings.")
        if ::File.exists?("/etc/sudoers.YaST2.new") # if file exists it is invalid syntax
          res = SCR.Execute(path(".target.bash_output"), "/usr/sbin/visudo -cf /etc/sudoers.YaST2.new")
          msg += _("\nSyntax error in target file. See /etc/sudoers.YaST2.new.\nDetails: ") + res["stdout"]
        end
        Report.Error(msg)
        ret = false
      end
      Builtins.sleep(sl)

      Progress.NextStage
      Builtins.sleep(sl)

      ret
    end

    publish :function => :GetModified, :type => "boolean ()"
    publish :function => :SetModified, :type => "void ()"
    publish :variable => :ValidCharsUsername, :type => "string"
    publish :variable => :all_users, :type => "list <string>"
    publish :function => :ReadLocalUsers, :type => "boolean ()"
    publish :function => :WriteSudoSettings2, :type => "boolean ()"
    publish :function => :SetItem, :type => "void (integer)"
    publish :function => :GetItem, :type => "integer ()"
    publish :function => :GetRules, :type => "list <map <string, any>> ()"
    publish :function => :RemoveRule, :type => "void (integer)"
    publish :function => :GetRule, :type => "map <string, any> (integer)"
    publish :function => :SetRule, :type => "void (integer, map <string, any>)"
    publish :function => :SearchRules, :type => "boolean (string, string)"
    publish :function => :SystemRulePopup, :type => "boolean (map <string, any>, boolean)"
    publish :function => :GetAliasNames, :type => "list <string> (string)"
    publish :function => :SearchAlias2, :type => "boolean (string, list <map <string, any>>)"
    publish :function => :GetUserAliases2, :type => "list <map <string, any>> ()"
    publish :function => :SetUserAlias, :type => "void (integer, map <string, any>)"
    publish :function => :RemoveUserAlias2, :type => "void (integer)"
    publish :function => :GetHostAliases2, :type => "list <map <string, any>> ()"
    publish :function => :RemoveHostAlias2, :type => "void (integer)"
    publish :function => :SetHostAlias, :type => "void (integer, map <string, any>)"
    publish :function => :GetRunAsAliases2, :type => "list <map <string, any>> ()"
    publish :function => :RemoveRunAsAlias2, :type => "void (integer)"
    publish :function => :SetRunAsAlias, :type => "void (integer, map <string, any>)"
    publish :function => :GetCmndAliases2, :type => "list <map <string, any>> ()"
    publish :function => :SetCmndAlias, :type => "void (integer, map <string, any>)"
    publish :function => :RemoveCmndAlias2, :type => "void (integer)"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :PollAbort, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
  end

  Sudo = SudoClass.new
  Sudo.main
end
