require_relative "test_helper"

Yast.import "Sudo"

describe Yast::Sudo do
  subject { described_class }

  describe "#ReadSudoSettings2" do
    before do
      # reset internal variables as e.g. read just adds new entries
      # and does not reset old
      subject.main
    end

    # @param lines [Array<Hash>] list of hash with keys :comment for
    #  comments before line, :type for first word on line, :name for the
    #  second and :rest for rest of line without initial "="
    def mock_sudo(lines)
      scr_result = lines.map do |l|
        [l[:comment] || "", l[:type], l[:name], l[:rest]]
      end
      allow(Yast::SCR).to receive(:Read).with(path(".sudo"))
        .and_return(scr_result)
    end

    it "parses and set host aliases" do
      lines = [
        { type: "Host_Alias", name: "ALIAS1", rest: "test.suse.cz" },
        { comment: "test\n", type: "Host_Alias", name: "ALIAS2",
          rest: "test.suse.de, test2.suse.de,\ttest3.suse.de" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "", "name" => "ALIAS1", "mem" => ["test.suse.cz"] },
        { "c" => "test\n", "name" => "ALIAS2",
          "mem" => ["test.suse.de", "test2.suse.de", "test3.suse.de"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetHostAliases2).to eq expected_aliases
    end

    it "parses and set user aliases" do
      lines = [
        { type: "User_Alias", name: "ALIAS1", rest: "user1" },
        { comment: "test\n", type: "User_Alias", name: "ALIAS2",
          rest: "user2, user3,\tuser4" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "", "name" => "ALIAS1", "mem" => ["user1"] },
        { "c" => "test\n", "name" => "ALIAS2",
          "mem" => ["user2", "user3", "user4"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetUserAliases2).to eq expected_aliases
    end

    it "parses and set command aliases" do
      lines = [
        { type: "Cmnd_Alias", name: "ALIAS1", rest: "/bin/cmd" },
        { comment: "test\n", type: "Cmnd_Alias", name: "ALIAS2",
          rest: "/bin/cmd1, /bin/cmd2,\t/bin/cmd3" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "", "name" => "ALIAS1", "mem" => ["/bin/cmd"] },
        { "c" => "test\n", "name" => "ALIAS2",
          "mem" => ["/bin/cmd1", "/bin/cmd2", "/bin/cmd3"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetCmndAliases2).to eq expected_aliases
    end

    it "parses and set command aliases with digest" do
      lines = [
        { comment: "test\n", type: "Cmnd_Alias", name: "ALIAS2",
          rest: "/bin/cmd1, sha224:0GomF8mNN3wlDt1HD9XldjJ3SNgpFdbjO1+NsQ== /home/cmds/cmd2" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "test\n", "name" => "ALIAS2",
          "mem" => ["/bin/cmd1", "sha224:0GomF8mNN3wlDt1HD9XldjJ3SNgpFdbjO1+NsQ== /home/cmds/cmd2"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetCmndAliases2).to eq expected_aliases
    end

    it "parses and set command aliases with Cmd_Alias alternative name" do
      pending "Not recognized yet"

      lines = [
        { comment: "test\n", type: "Cmd_Alias", name: "ALIAS2", rest: "/bin/cmd1" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "test\n", "name" => "ALIAS2", "mem" => ["/bin/cmd1"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetCmndAliases2).to eq expected_aliases
    end

    it "parses and set runas aliases" do
      lines = [
        { type: "Runas_Alias", name: "ALIAS1", rest: "user" },
        { comment: "test\n", type: "Runas_Alias", name: "ALIAS2",
          rest: "user1, user2,\tuser3" }
      ]
      mock_sudo(lines)

      expected_aliases = [
        { "c" => "", "name" => "ALIAS1", "mem" => ["user"] },
        { "c" => "test\n", "name" => "ALIAS2",
          "mem" => ["user1", "user2", "user3"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetRunAsAliases2).to eq expected_aliases
    end

    it "parses and set rules" do
      lines = [
        { type: "user1", name: "ALL", rest: "NOPASSWD: /usr/bin/su operator" },
        { comment: "test\n", type: "user1", name: "ALL",
          rest: "/bin/adduser, /bin/rmuser" }
      ]
      mock_sudo(lines)

      expected_rules = [
        { "user" => "user1", "host" => "ALL", "comment" => "",
          "tag" => "NOPASSWD:", "commands" => ["/usr/bin/su operator"] },
        { "user" => "user1", "host" => "ALL", "comment" => "test\n",
          "commands" => ["/bin/adduser", "/bin/rmuser"] }
      ]

      subject.ReadSudoSettings2

      expect(subject.GetRules).to eq expected_rules
    end

    it "raises UnsupportedSudoConfig for rules with multiple tags" do
      lines = [
        { type: "user1", name: "ALL", rest: "NOPASSWD:NOEXEC: /usr/bin/su operator" },
      ]
      mock_sudo(lines)

      expect{subject.ReadSudoSettings2}.to raise_error(Yast::UnsupportedSudoConfig)
    end

    it "raises UnsupportedSudoConfig for rules with associated tags" do
      lines = [
        { type: "user1", name: "ALL", rest: "NOPASSWD: /usr/bin/su operator, PASSWD: /bin/test" },
      ]
      mock_sudo(lines)

      expect{subject.ReadSudoSettings2}.to raise_error(Yast::UnsupportedSudoConfig)
    end

    it "parses and set rules with run as specified" do
      lines = [
        # (root, bin : operator, system) means can run as root or bin user or as operator or system group
        { type: "user1", name: "ALL", rest: "NOPASSWD: (root, bin : operator, system) /bin/test" },
      ]
      mock_sudo(lines)

      expected_rules = [
        { "user" => "user1", "host" => "ALL", "comment" => "", "run_as" => "(root, bin : operator, system)",
          "tag" => "NOPASSWD:", "commands" => ["/bin/test"] },
      ]

      subject.ReadSudoSettings2

      expect(subject.GetRules).to eq expected_rules
    end

    it "raises UnsupportedSudoConfig for rules with digest" do
      lines = [
        { type: "sha256:865d0fc47d0aa1fe198e2d9b0cd5b27e35838dc8f73b6629adc646d3cc2d9c94",
          name: "user1" },
      ]
      mock_sudo(lines)

      expect{subject.ReadSudoSettings2}.to raise_error(Yast::UnsupportedSudoConfig)
    end
  end
end
