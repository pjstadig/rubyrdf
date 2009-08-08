require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::NTriples do
  describe "escape" do
    it "should escape tab" do
      RubyRDF::NTriples.escape("\x9").should == '\\t'
    end

    it "should escape newline" do
      RubyRDF::NTriples.escape("\xA").should == '\\n'
    end

    it "should escape carriage return" do
      RubyRDF::NTriples.escape("\xD").should == '\\r'
    end

    it "should escape dquote" do
      RubyRDF::NTriples.escape("\x22").should == '\\"'
    end

    it "should escape backslash" do
      RubyRDF::NTriples.escape("\x5C").should == '\\\\'
    end
  end

  describe "escape_unicode" do
    it "should escape 0x0" do
      RubyRDF::NTriples.escape_unicode("\x0").should == "\\u0000"
    end

    it "should escape 0x8" do
      RubyRDF::NTriples.escape_unicode("\x8").should == "\\u0008"
    end

    it "should escape 0xB" do
      RubyRDF::NTriples.escape_unicode("\xB").should == "\\u000B"
    end

    it "should escape 0xC" do
      RubyRDF::NTriples.escape_unicode("\xC").should == "\\u000C"
    end

    it "should escape 0xE" do
      RubyRDF::NTriples.escape_unicode("\xE").should == "\\u000E"
    end

    it "should escape 0x1F" do
      RubyRDF::NTriples.escape_unicode("\x1F").should == "\\u001F"
    end

    it "should not escape 0x20" do
      RubyRDF::NTriples.escape_unicode("\x20").should == "\x20"
    end

    it "should not escape 0x21" do
      RubyRDF::NTriples.escape_unicode("\x21").should == "\x21"
    end

    it "should not escape 0x23" do
      RubyRDF::NTriples.escape_unicode("\x23").should == "\x23"
    end

    it "should not escape 0x5B" do
      RubyRDF::NTriples.escape_unicode("\x5B").should == "\x5B"
    end

    it "should not escape 0x5D" do
      RubyRDF::NTriples.escape_unicode("\x5D").should == "\x5D"
    end

    it "should not escape 0x7E" do
      RubyRDF::NTriples.escape_unicode("\x7E").should == "\x7E"
    end

    it "should escape 0x7F" do
      RubyRDF::NTriples.escape_unicode("\x7F").should == "\\u007F"
    end

    it "should escape 0xFFFF" do
      RubyRDF::NTriples.escape_unicode([0xFFFF].pack("U")).should == "\\uFFFF"
    end

    it "should escape 0x10000" do
      RubyRDF::NTriples.escape_unicode([0x10000].pack("U")).should == "\\U00010000"
    end

    it "should escape 0x10FFFF" do
      RubyRDF::NTriples.escape_unicode([0x10FFFF].pack("U")).should == "\\U0010FFFF"
    end

    it "should raise invalid character" do
      lambda {
        RubyRDF::NTriples.escape_unicode([0x110000].pack("U"))
      }.should raise_error(RubyRDF::NTriples::InvalidCharacterError)
    end
  end

  describe "unescape" do
    it "should unescape \\t" do
      RubyRDF::NTriples.unescape("\\t").should == "\x9"
    end

    it "should unescape \\n" do
      RubyRDF::NTriples.unescape("\\n").should == "\xA"
    end

    it "should unescape \\r" do
      RubyRDF::NTriples.unescape("\\r").should == "\xD"
    end

    it "should unescape \\\"" do
      RubyRDF::NTriples.unescape('\\"').should == "\x22"
    end

    it "should unescape \\\\" do
      RubyRDF::NTriples.unescape("\\\\").should == "\x5C"
    end
  end

  describe "unescape_unicode" do
    it "should decode \\u encoding" do
      RubyRDF::NTriples.unescape_unicode("\\u20AC").should == [0x20AC].pack("U")
    end

    it "should raise error for \\u encoding with less than four hexadecimal characters" do
      lambda{
        RubyRDF::NTriples.unescape_unicode("\\u2AC")
      }.should raise_error(RubyRDF::NTriples::SyntaxError)
    end

    it "should decode \\U encoding" do
      RubyRDF::NTriples.unescape_unicode("\\U00010000").should == [0x10000].pack("U")
    end

    it "should raise error for \\U encoding with less than eight hexadecimal characters" do
      lambda {
        RubyRDF::NTriples.unescape_unicode("\\U0010000")
      }.should raise_error(RubyRDF::NTriples::SyntaxError)
    end

    it "should raise error for \\U encoding with greater than 10FFFF" do
      lambda {
        RubyRDF::NTriples.unescape_unicode("\\U00110000")
      }.should raise_error(RubyRDF::NTriples::InvalidCharacterError)
    end
  end
end
