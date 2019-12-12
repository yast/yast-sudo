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

require_relative "../test_helper"
require "cfa/sudoers"
require "tmpdir"

describe CFA::Sudoers do
  subject(:sudoers) { described_class.new(file_path: file_path) }

  let(:file_path) { example_file }
  let(:example_file) { File.join(DATA_PATH, "sudoers_example") }

  let(:yast_user_spec) do
    {
      "user"     => "yast",
      "host"     => "ALL",
      "run_as"   => "root",
      "commands" => ["/sbin/yast2"],
      "tag"      => "NOPASSWD"
    }
  end

  let(:cli_user_spec) do
    {
      "user"     => "cli",
      "host"     => "ALL",
      "run_as"   => "ALL",
      "commands" => ["/sbin/yast"]
    }
  end

  describe ".load" do
    it "loads the file content" do
      expect(described_class).to receive(:new)
        .with(hash_including(file_path: file_path))
        .and_call_original

      file = described_class.load(file_path: file_path)

      expect(file.loaded?).to eq(true)
    end
  end

  describe "#load" do
    it "loads the file content" do
      expect { sudoers.load }.to change { sudoers.loaded? }.from(false).to(true)
    end
  end

  describe "#users_specs" do
    before { sudoers.load }

    context "when the loaded file already contains user spec" do
      it "returns a collection holding all user specs" do
        expect(sudoers.users_specs).to eq([
          { "user" => "ALL", "host" => "ALL", "run_as" => "ALL", "commands" => ["ALL"], },
          { "user" => "root", "host" => "ALL", "run_as" => "ALL", "commands" => ["ALL"], }
        ])
      end
    end

    context "when the loaded file does not contain user specs yet" do
      let(:file_path) { File.join(DATA_PATH, "sudoers_no_specs_example") }

      it "return an empty collection" do
        expect(sudoers.users_specs).to eq([])
      end

      context "but a new user specs were added" do
        before do
          sudoers.add_user(yast_user_spec)
          sudoers.add_user(cli_user_spec)
        end

        it "returns a collection holding all user specs" do
          expect(sudoers.users_specs).to eq([yast_user_spec, cli_user_spec])
        end
      end
    end
  end

  describe "#clean_users" do
    before { sudoers.load }

    it "removes all users specifications" do
      initial_users_specs = sudoers.users_specs

      sudoers.clean_users

      expect(sudoers.users_specs).to_not eq(initial_users_specs)
      expect(sudoers.users_specs).to eq([])
    end
  end

  describe "#save" do
    let(:file_path) { File.join(tmpdir, "sudoers") }
    let(:tmpdir) { Dir.mktmpdir }

    before do
      # Use a copy of the example file
      FileUtils.cp(example_file, file_path)

      sudoers.load
    end

    after do
      FileUtils.remove_entry(tmpdir)
    end

    context "when the file does not contain user specifications" do
      let(:example_file) { File.join(DATA_PATH, "sudoers_no_specs_example") }

      context "nor does it include the #includedir sudoers.d directive" do
        let(:example_file) { File.join(DATA_PATH, "sudoers_old_example") }

        it "writes new specifications at the end of file" do
          sudoers.add_user(yast_user_spec)
          sudoers.add_user(cli_user_spec)
          sudoers.save

          expect(File.read(file_path)).to match(/.*cli ALL = \(ALL\) \/sbin\/yast\Z/)
        end
      end

      context "but does include the #includedir sudoers.d directive" do
        it "writes new specifications before it" do
          sudoers.add_user(yast_user_spec)
          sudoers.add_user(cli_user_spec)
          sudoers.save

          expect(File.read(file_path)).to match(/.*yast.*cli.*\#includedir.*sudoers\.d.*/m)
        end
      end
    end

    context "when the file already contains user specs" do
      it "writes new specifications after them" do
        sudoers.add_user(yast_user_spec)
        sudoers.add_user(cli_user_spec)
        sudoers.save

        expect(File.read(file_path)).to include(
          "root ALL=(ALL) ALL\n" \
          "yast ALL = (root) NOPASSWD : /sbin/yast2\n" \
          "cli ALL = (ALL) /sbin/yast\n"
        )
      end

      context "but they are cleaned before start adding new ones" do
        it "writes new specs starting in the previous ones position" do
          previous_first_position = File.read(file_path) =~ /.*^ALL.*ALL.*=\(ALL\)/

          sudoers.clean_users
          sudoers.add_user(yast_user_spec)
          sudoers.add_user(cli_user_spec)
          sudoers.save

          new_first_position = File.read(file_path) =~ /.*^yast.*ALL.*=/

          expect(new_first_position).to eq(previous_first_position)
        end

      end
    end
  end
end
