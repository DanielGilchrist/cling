require "./spec_helper"

describe Cling::Parser do
  it "parses standard input arguments" do
    parser = Cling::Parser.new %(these --are "some" -c arguments)
    results = parser.parse

    results[0].kind.should eq Cling::Parser::Result::Kind::Argument
    results[1].kind.should eq Cling::Parser::Result::Kind::LongFlag
    results[2].kind.should eq Cling::Parser::Result::Kind::Argument
    results[3].kind.should eq Cling::Parser::Result::Kind::ShortFlag
    results[4].kind.should eq Cling::Parser::Result::Kind::Argument
  end

  it "parses custom flag input arguments" do
    options = Cling::Parser::Options.new option_delim: '+'
    parser = Cling::Parser.new %(these ++are "some" +c arguments), options
    results = parser.parse

    results[0].kind.should eq Cling::Parser::Result::Kind::Argument
    results[1].kind.should eq Cling::Parser::Result::Kind::LongFlag
    results[2].kind.should eq Cling::Parser::Result::Kind::Argument
    results[3].kind.should eq Cling::Parser::Result::Kind::ShortFlag
    results[4].kind.should eq Cling::Parser::Result::Kind::Argument
  end

  it "parses a string argument" do
    parser = Cling::Parser.new %(--test "string argument" -t)
    results = parser.parse

    results[0].kind.should eq Cling::Parser::Result::Kind::LongFlag
    results[1].kind.should eq Cling::Parser::Result::Kind::Argument
    results[1].value.should eq "string argument"
    results[2].kind.should eq Cling::Parser::Result::Kind::ShortFlag
  end

  it "parses an option argument" do
    parser = Cling::Parser.new %(--name=foo -k=bar)
    results = parser.parse

    results[0].kind.should eq Cling::Parser::Result::Kind::LongFlag
    results[0].key.should eq "name"
    results[0].value.should eq "foo"

    results[1].kind.should eq Cling::Parser::Result::Kind::ShortFlag
    results[1].key.should eq "k"
    results[1].value.should eq "bar"
  end

  it "parses an array argument" do
    parser = Cling::Parser.new %(-n 1 -n=2,3 -n 4)
    results = parser.parse

    results[0].kind.should eq Cling::Parser::Result::Kind::ShortFlag
    results[0].key.should eq "n"
    results[0].value.should be_nil
    results[1].value.should eq "1"
    # This isn't managed by the parser so this is the raw value,
    # the executor will parse this into ["2", "3"]
    results[2].value.should eq "2,3"
    results[3].value.should be_nil
    results[4].value.should eq "4"
  end
end
