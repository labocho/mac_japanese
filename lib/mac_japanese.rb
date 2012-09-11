require "mac_japanese/version"
require "strscan"

module MacJapanese
  autoload :DECOMPOSED_OR_NORMAL_CHARACTER_REGEXP, "mac_japanese/decomposed_or_normal_character_regexp"
  autoload :MAC_JAPANESE_TO_UTF8_WITH_PUA, "mac_japanese/mac_japanese_to_utf8_with_pua"
  autoload :MAC_JAPANESE_TO_UTF8_WITHOUT_PUA, "mac_japanese/mac_japanese_to_utf8_without_pua"
  autoload :UTF8_TO_MAC_JAPANESE, "mac_japanese/utf8_to_mac_japanese"

  module_function
  def to_utf8(src, options = {})
    use_pua = options.has_key?(:use_pua) ? options.delete(:use_pua) : true
    options[:replace] ||= "\u{fffd}"

    src = src.dup.force_encoding(Encoding::MacJapanese) unless src.encoding == Encoding::MacJapanese
    table = use_pua ? MAC_JAPANESE_TO_UTF8_WITH_PUA : MAC_JAPANESE_TO_UTF8_WITHOUT_PUA

    dest = ""
    # If you use StringScanner here,
    # raise exception for string includes 0x80, 0xA0, 0xFD, 0xFE, or 0xFF.
    src.chars.each do |char|
      dest << convert_char(char, table, Encoding::MacJapanese, Encoding::UTF_8, options)
    end
    dest
  end

  def to_mac_japanese(src, options = {})
    options[:replace] ||= "?"

    src = encode_or_raise(src, Encoding::UTF_8, options)
    table = UTF8_TO_MAC_JAPANESE

    dest = ""

    ss = StringScanner.new(src)
    while char = ss.scan(DECOMPOSED_OR_NORMAL_CHARACTER_REGEXP)
      dest << convert_char(char, table, Encoding::UTF_8, Encoding::MacJapanese, options)
    end
    dest
  end

  class << self
    private
    # convert single character or decomposed characters by table
    # using from|to encoding for make error message.
    def convert_char(char, table, from, to, options)
      unless converted_char = table[char]
        if char.size > 1
          return char.chars.map{|c|
            convert_char(c, table, from, to, options)
          }.join
        end

        if options[:undef] == :replace
          converted_char = options[:replace]
        else # default
          message = "#{char.inspect} from #{from.name} to #{to.name}"
          raise Encoding::UndefinedConversionError, message
        end
      end
      converted_char
    end

    def encode_or_raise(src, encoding, options)
      src.encode(encoding, options)
    rescue EncodingError
      raise EncodingError, "Source string must be able to encode to #{encoding.name}"
    end
  end
end
