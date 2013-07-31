# encoding: utf-8

module Yast
  class SudoClient < Client
    def main
      # testedfiles: Sudo.ycp

      Yast.include self, "testsuite.rb"
      TESTSUITE_INIT([], nil)

      Yast.import "Sudo"

      DUMP("Sudo::GetModified")
      TEST(lambda { Sudo.GetModified }, [], nil)

      nil
    end
  end
end

Yast::SudoClient.new.main
