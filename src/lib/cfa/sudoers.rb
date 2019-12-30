# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "yast"
require "yast2/target_file"
require "cfa/base_model"
require "cfa/augeas_parser"
require "cfa/matcher"
require "cfa/placer"

module CFA
  # Model to handle users specifications in the /etc/sudoers file
  #
  # @example Loading specifications
  #   file = Sudoers.new
  #   file.load
  #   file.user_specs
  #
  # @example Shortcut loading specificitions
  #   Sudoers.read.users_specs
  #
  # @example Updating user specifications specifications
  #   file = Sudores.new
  #   file.load
  #   file.clean_users
  #   file.add_user("user" => "yast", "host" => "ALL", "commands" => ["/sbin/yast2"])
  #   file.add_user("user" => "foo", "host" => "ALL", "commands" => ["ALL"], "tag" => "NOPASSWD")
  #   file.save
  class Sudoers < BaseModel
    # @return [String] default path to the sudoers file
    DEFAULT_PATH = "/etc/sudoers".freeze
    private_constant :DEFAULT_PATH

    # @return [Matcher] matcher for the users collection
    USERS_MATCHER = Matcher.new(collection: "spec")
    private_constant :USERS_MATCHER

    class << self
      # Instantiates the model and loads the file content
      #
      # Since it is basically a shortcut of Sudoers.new(...).load, every call to it will produce a
      # new model instance. In other words, Sudoers.read !== Sudoers.read.
      #
      # @param file_handler [#read,#write] something able to read/write a string (like File)
      # @return [Sudoers] Model with the already loaded content
      def read(file_path: DEFAULT_PATH, file_handler: nil)
        new(file_path: file_path, file_handler: file_handler).tap(&:load)
      end
    end

    # Constructor
    #
    # @param file_handler [#read,#write] something able to read/write a string (like File)
    #
    # @see CFA::BaseModel#initialize
    def initialize(file_path: DEFAULT_PATH, file_handler: nil)
      super(AugeasParser.new("sudoers.lns"), file_path, file_handler: file_handler)
    end

    # Read and prepare the data
    #
    # @see CFA::BaseModel#initialize
    # @see #fix_collection_names
    # @see #set_start_placer
    def load
      super

      fix_collection_names(data)
      @start_placer = set_start_placer
    end

    # Return all users specifications
    #
    # @return [Array<Hash>]
    def users_specs
      current_users.reduce([]) do |specs, user|
        spec = {}
        values = user[:value]

        spec["user"] = values["user"]
        spec["host"] = values["host_group"]["host"]
        spec["commands"] = values["host_group"].collection("command").map do |command|
          command.is_a?(AugeasTreeValue) ? command.value : command
        end
        spec["run_as"] = values["host_group"]["command[]"]["runas_user"]
        spec["tag"] = values["host_group"]["command[]"]["tag"]

        specs << spec.reject { |_, v| v.nil? }
      end
    end

    # Remove all users specifications
    def clean_users
      data.delete(USERS_MATCHER)
    end

    # Add a new basic user specification
    #
    #
    # A user specification determines which commands a user may run (and as what user) on specified
    # hosts (who may run what, for short).
    #
    # Its basic structure is “who where = (as_whom) what”.
    #
    # E.g., with
    #
    #   root            ALL = (ALL) ALL
    #   %wheel          ALL = (ALL) ALL
    #
    #   We let root and any user in group wheel run any command on any host as any user.
    #
    # See the sudoers manpage for more details.
    #
    # TODO: should we use an specialized class to build the user specs and improve how the
    # validations and actions are performed?
    #
    # @param user_spec [Hash] a user specification
    # @option user_spec [String] "user" who can run the command
    # @option user_spec [String] "host" where the user can run the command
    # @option user_spec [String, Array<String>] "commands" commands that the user can run
    # @option user_spec [String] "run_as" as whom the commands will be run
    # @option user_spec [String] "tag" the tag associated to the command (e.g. NOPASSWD)
    #
    # @raise [ArgumentError] when "user", "host", or "commands" are not given or are empty.
    def add_user(user_spec)
      commands = Array(user_spec["commands"]).reject { |c| c.to_s.strip.empty? }

      raise ArgumentError.new("user must be given") if user_spec["user"].to_s.strip.empty?
      raise ArgumentError.new("host must be given") if user_spec["host"].to_s.strip.empty?
      raise ArgumentError.new("at least one command must be specified") if commands.size.zero?

      user = AugeasTree.new
      host_group = AugeasTree.new

      host_group.add("host", user_spec["host"])

      augeas_commands = commands.reduce([]) do |augeas_commands, command|
        augeas_command = AugeasTree.new
        host_group.add("command[]", AugeasTreeValue.new(augeas_command, command))
        augeas_commands << augeas_command
      end

      # For the time being, "runas_user" and "tag" options are added only to the first command,
      # which means that they apply to all commands.
      run_as = user_spec["run_as"].to_s.strip
      tag = user_spec["tag"].to_s.strip
      augeas_commands[0].add("runas_user", run_as) unless run_as.empty?
      augeas_commands[0].add("tag", tag) unless tag.empty?

      user.add("user", user_spec["user"])
      user.add("host_group", host_group)

      data.add("spec[]", user, placer)
    end

    private

    attr_accessor :start_placer

    # Return the current users collection
    #
    # @important DO NOT modify the returned structure since it is an AugeasTree internal structure
    # that can change.
    #
    # @return [Array<Hash>]
    def current_users
      data.select(USERS_MATCHER)
    end

    COLLECTION_KEYS = ["spec", "command"].freeze
    private_constant :COLLECTION_KEYS

    # Fix collection names adding the missing "[]"
    #
    # When a collection has only one element, Augeas does not add "[]" suffix, reason why is
    # necessary to fix at least those collextions that are going to be hitted for either, read or
    # write.
    #
    # @param tree [AugeasTree,AugeasTreeValue]
    def fix_collection_names(tree)
      tree.data.each do |entry|
        key, value = entry.values_at(:key, :value)

        entry[:key] << "[]" if COLLECTION_KEYS.include?(key)
        fix_collection_names(value) if value.is_a?(AugeasTree)
        fix_collection_names(value.tree) if value.is_a?(AugeasTreeValue)
      end
    end

    # Return the "next" placer where the user specification should be write
    #
    # When there are not users specifications yet, the start placer will be use. Otherwise, a new
    # specification will be placed after the last one.
    #
    # @see #add_user
    # @see #set_start_placer
    #
    # @return [CFA::Placer]
    def placer
      return start_placer if current_users.empty?

      last_user = current_users.last

      AfterPlacer.new(Matcher.new(key: last_user[:key], value_matcher: last_user[:value]))
    end

    # Set the the placer for the first user specification
    #
    # Depending on the defined users specifications, one of following criterias will be applied
    #
    #   * Generates the placer **after** the first one, or
    #   * Look for the "#includedir .*sudoers.d.*" directive and generates the placer **before** it
    #     if there are not users specifications yet.
    #
    # @see #placer
    #
    # @return [CFA::Placer]
    def set_start_placer
      first_user = current_users.first

      if first_user
        matcher = Matcher.new(key: first_user[:key], value_matcher: first_user[:value])

        # This will work even after call #clean_users because the matcher searches over
        # AugeasTree#all_data, which includes also the entries marked to be removed.
        AfterPlacer.new(matcher)
      else
        matcher = Matcher.new(key: "#includedir", value_matcher: /sudoers\.d/)

        BeforePlacer.new(matcher)
      end
    end
  end
end
