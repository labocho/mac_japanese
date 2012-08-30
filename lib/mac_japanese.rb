require "mac_japanese/version"

module MacJapanese
  autoload :MAC_JAPANESE_TO_UTF8_WITH_PUA, "mac_japanese/mac_japanese_to_utf8_with_pua"
  autoload :MAC_JAPANESE_TO_UTF8_WITHOUT_PUA, "mac_japanese/mac_japanese_to_utf8_without_pua"
  autoload :UTF8_TO_MAC_JAPANESE, "mac_japanese/utf8_to_mac_japanese"

  module_function
  def to_utf8(src, options = {})
    use_pua = options.delete(:use_pua)
    options[:replace] ||= "\u{fffd}"
    src = encode_or_raise(src, Encoding::MacJapanese, options)
    table = use_pua ? MAC_JAPANESE_TO_UTF8_WITH_PUA : MAC_JAPANESE_TO_UTF8_WITHOUT_PUA
    convert_by_table(src, table, options)
  end

  def to_mac_japanese(src, options = {})
    options[:replace] ||= "?"
    src = encode_or_raise(src, Encoding::UTF_8, options)
    table = UTF8_TO_MAC_JAPANESE
    convert_by_table(src, table, options)
  end

  class << self
    private
    def convert_by_table(src, table, options)
      dest = ""
      src.chars.each do |char|
        unless macjp_string = table[char]
          if options[:undef] == :replace
            macjp_string = options[:replace]
          else # default
            raise Encoding::UndefinedConversionError, "#{char.inspect}"
          end
        end
        dest << macjp_string
      end
      dest
    end

    def encode_or_raise(src, encoding, options)
      src.encode(encoding, options)
    rescue EncodingError
      raise EncodingError, "Source string must be able to encode to #{encoding.name}"
    end
  end
end
