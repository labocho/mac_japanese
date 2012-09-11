require "spec_helper"
require "ruby-debug"

describe MacJapanese do
  describe ".to_utf" do
    [true, false].each do |use_pua|
      context "#{use_pua ? "use" : "not use"} pua" do
        let(:options) { {} }
        subject { MacJapanese.to_utf8(@src, options.merge(use_pua: use_pua)) }
        it "should convert us-ascii chars to utf8" do
          @src = "foo\n".force_encoding("macjapan")
          should == "foo\n"
        end
        it "should convert additional backslash to utf8" do
          @src = "\x80".force_encoding("macjapan")
          should == "\\"
        end
        it "should convert halfwidth katakana to utf8" do
          @src = "\xA7".force_encoding("macjapan")
          should == "\u{FF67}"
        end
        it "should convert hiragana to utf8" do
          @src = "\x82\x9F".force_encoding("macjapan")
          should == "\u{3041}"
        end
        it "should convert apple additions to utf8" do
          @src = "\x85\x5E".force_encoding("macjapan")
          should == "\u{2474}"
        end
      end
    end
    context "default" do
      subject { MacJapanese.to_utf8(@src) }
      it "should expand composed char with pua" do
        @src = "\x85\xAB".force_encoding("macjapan")
        should == "\u{F862}\u{0058}\u{0049}\u{0049}\u{0049}"
      end
    end
    context "use_pua" do
      subject { MacJapanese.to_utf8(@src, use_pua: true) }
      it "should expand composed char with pua" do
        @src = "\x85\xAB".force_encoding("macjapan")
        should == "\u{F862}\u{0058}\u{0049}\u{0049}\u{0049}"
      end
    end
    context "use_pua" do
      subject { MacJapanese.to_utf8(@src, use_pua: false) }
      it "should expand composed char without pua" do
        @src = "\x85\xAB".force_encoding("macjapan")
        should == "\u{0058}\u{0049}\u{0049}\u{0049}"
      end
    end
    context "pass another encoding string to .to_utf8" do
      it "should encode just like passing mac japanese string" do
        @src = "\x82\x9F"
        @src.encoding.should == Encoding::ASCII_8BIT
        MacJapanese.to_utf8(@src).should == "\u{3041}"
      end
    end
  end

  describe ".to_mac_japanese" do
    let(:options) { {} }
    subject { MacJapanese.to_mac_japanese(@src, options) }
    it "should convert us-ascii chars to mac_japanese" do
      @src = "foo\n"
      should == "foo\n".force_encoding("macjapan")
    end
    it "should convert additional backslash to mac_japanese" do
      @src = "\\"
      should == "\x80".force_encoding("macjapan")
    end
    it "should convert halfwidth katakana to mac_japanese" do
      @src = "\u{FF67}"
      should == "\xA7".force_encoding("macjapan")
    end
    it "should convert hiragana to mac_japanese" do
      @src = "\u{3041}"
      should == "\x82\x9F".force_encoding("macjapan")
    end
    it "should convert hiragana followed by composed characters to mac_japanese" do
      @src = "\u{3041}\u{F862}\u{0058}\u{0049}\u{0049}\u{0049}"
      should == "\x82\x9F\x85\xAB".force_encoding("macjapan")
    end
    it "should convert apple additions to mac_japanese" do
      @src = "\u{2474}"
      should == "\x85\x5E".force_encoding("macjapan")
    end
    it "should compose characters with pua" do
      @src = "\u{F862}\u{0058}\u{0049}\u{0049}\u{0049}"
      should == "\x85\xAB".force_encoding("macjapan")
    end
    it "should not compose characters without pua" do
      @src = "\u{0058}\u{0049}\u{0049}\u{0049}"
      should == "XIII".force_encoding("macjapan")
    end
    context "pass another encoding string to .to_mac_japanese" do
      it "should encode to mac japanese string (via utf8)" do
        @src = "\u{3041}".encode("euc-jp")
        MacJapanese.to_mac_japanese(@src).should == "\x82\x9F".force_encoding("macjapan")
      end
    end
  end

  context "undef: :replace" do
    it "should replace undefined mac japanese char" do
      @src = "foo\xFC\xFCbar".force_encoding("macjapan")
      MacJapanese.to_utf8(@src, undef: :replace).should == "foo\u{fffd}bar"
    end
    it "should replace undefined utf-8 char" do
      @src = "foo\u{FA11}bar"
      MacJapanese.to_mac_japanese(@src, undef: :replace).should == "foo?bar"
    end
    it "should replace with replace option" do
      @src = "foo\xFC\xFCbar".force_encoding("macjapan")
      MacJapanese.to_utf8(@src, undef: :replace, replace: "*").should == "foo*bar"
    end
  end

  context "undef: (none)" do
    it "should raise Encoding::UndefinedConversionError" do
      @src = "foo\xFC\xFCbar".force_encoding("macjapan")
      expect{
        MacJapanese.to_utf8(@src)
      }.to raise_error(Encoding::UndefinedConversionError)
    end
    it "should replace undefined mac utf-8 char" do
      @src = "foo\u{FA11}bar"
      expect{
        MacJapanese.to_mac_japanese(@src).should == "foo?bar"
      }.to raise_error(Encoding::UndefinedConversionError)
    end
  end
end
