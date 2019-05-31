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

# File:	include/sudo/wizards.ycp
# Package:	Configuration of sudo
# Summary:	Wizards definitions
# Authors:	Bubli <kmachalkova@suse.cz>
#
# $Id: wizards.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SudoWizardsInclude
    def initialize_sudo_wizards(include_target)
      Yast.import "UI"

      textdomain "sudo"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "sudo/complex.rb"
      Yast.include include_target, "sudo/dialogs.rb"
      Yast.include include_target, "sudo/dialog-spec.rb"
      Yast.include include_target, "sudo/dialog-user.rb"
      Yast.include include_target, "sudo/dialog-host.rb"
      Yast.include include_target, "sudo/dialog-runas.rb"
      Yast.include include_target, "sudo/dialog-cmnd.rb"
    end

    # Main workflow of sudo configuration

    def MainSequence
      aliases = {
        "configuration"    => lambda { RunSudoDialogs() },
        "user_spec_add"    => lambda { AddEditUserSpecDialog("Add") },
        "user_spec_edit"   => lambda { AddEditUserSpecDialog("Edit") },
        "user_spec_save"   => lambda { SaveUserSpec() },
        "user_alias_add"   => lambda { AddEditUserAliasDialog("Add") },
        "user_alias_edit"  => lambda { AddEditUserAliasDialog("Edit") },
        "user_alias_save"  => lambda { SaveUserAliases() },
        "host_alias_add"   => lambda { AddEditHostAliasDialog("Add") },
        "host_alias_edit"  => lambda { AddEditHostAliasDialog("Edit") },
        "host_alias_save"  => lambda { SaveHostAliases() },
        "runas_alias_add"  => lambda { AddEditRunAsAliasDialog("Add") },
        "runas_alias_edit" => lambda { AddEditRunAsAliasDialog("Edit") },
        "runas_alias_save" => lambda { SaveRunAsAliases() },
        "cmnd_alias_add"   => lambda { AddEditCmndAliasDialog("Add") },
        "cmnd_alias_edit"  => lambda { AddEditCmndAliasDialog("Edit") }
      }

      sequence = {
        "ws_start"         => "configuration",
        "configuration"    => {
          :add_spec     => "user_spec_add",
          :edit_spec    => "user_spec_edit",
          :add_u_alias  => "user_alias_add",
          :edit_u_alias => "user_alias_edit",
          :add_h_alias  => "host_alias_add",
          :edit_h_alias => "host_alias_edit",
          :add_r_alias  => "runas_alias_add",
          :edit_r_alias => "runas_alias_edit",
          :save_r_alias => "runas_alias_save",
          :add_c_alias  => "cmnd_alias_add",
          :edit_c_alias => "cmnd_alias_edit",
          :abort        => :abort,
          :next         => :next
        },
        "user_spec_add"    => { :abort => :abort, :next => "user_spec_save" },
        "user_spec_edit"   => { :abort => :abort, :next => "user_spec_save" },
        "user_spec_save"   => { :abort => :abort, :next => "configuration" },
        "user_alias_add"   => { :abort => :abort, :next => "user_alias_save" },
        "user_alias_edit"  => { :abort => :abort, :next => "user_alias_save" },
        "user_alias_save"  => { :abort => :abort, :next => "configuration" },
        "host_alias_add"   => { :abort => :abort, :next => "configuration" },
        "host_alias_edit"  => { :abort => :abort, :next => "configuration" },
        "runas_alias_add"  => { :abort => :abort, :next => "configuration" },
        "runas_alias_edit" => { :abort => :abort, :next => "configuration" },
        "cmnd_alias_add"   => { :abort => :abort, :next => "configuration" },
        "cmnd_alias_edit"  => { :abort => :abort, :next => "configuration" }
      }
      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    # Whole configuration of sudo
    # @return sequence result
    def SudoSequence
      aliases = { "main" => lambda { MainSequence() }, "write" => [lambda do
        WriteDialog()
      end, true] }

      sequence = {
        "ws_start" => "main",
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("org.openSUSE.YaST.Sudo")
      return :abort if !Sudo.Read

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
