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

# File:	clients/sudo.ycp
# Package:	Configuration of sudo
# Summary:	Main file
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: sudo.ycp 27914 2006-02-13 14:32:08Z locilka $
#
# Main file for sudo configuration. Uses all other files.
module Yast
  class SudoClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of sudo</h3>

      textdomain "sudo"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Sudo module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"

      Yast.import "CommandLine"
      Yast.include self, "sudo/wizards.rb"

      @cmdline_description = {
        "id"         => "sudo",
        # Command line help text for the Xsudo module
        "help"       => _(
          "Configuration of sudo"
        ),
        "guihandler" => fun_ref(method(:SudoSequence), "any ()"),
        "initialize" => fun_ref(Sudo.method(:Read), "boolean ()"),
        "finish"     => fun_ref(Sudo.method(:Write), "boolean ()"),
        "actions" =>
          # FIXME TODO: fill the functionality description here
          {},
        "options" =>
          # FIXME TODO: fill the option descriptions here
          {},
        "mappings" =>
          # FIXME TODO: fill the mappings of actions and options here
          {}
      }


      # main ui function
      @ret = nil

      @ret = CommandLine.Run(@cmdline_description)
      Builtins.y2debug("ret=%1", @ret)

      # Finish
      Builtins.y2milestone("Sudo module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::SudoClient.new.main
