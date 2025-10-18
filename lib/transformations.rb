module Transformations
  module_function

  # Binär(16) -> "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  def bin_to_str(bin)
    return nil unless bin
    hex = bin.unpack1("H*")
    [hex[0,8], hex[8,4], hex[12,4], hex[16,4], hex[20,12]].join("-")
  end

  # "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -> Binär(16)
  def str_to_bin(str)
    return nil unless str
    hex = str.delete("-")
    [hex].pack("H*")
  end

  def strip_artefacts(str)
    str.gsub(/\[nbsp\]/,"")
  end

  def unserialize(str)
    str ? PHP.unserialize(str) : []
  end

  def datetime_from_int(int)
    Time.at(int).to_datetime
  end

  def accept_keys!(value, keys)
    keys.to_h { |k| [k, value.to_h[k]] }
  end

  def reject_empty(data, key)
    data[key].to_s.length > 0 ? data : nil
  end

  def sort(value, key)
    value.sort_by{ _1[key] }
  end

  def uri_escape(str)
    URI::Parser.new.escape(str)
  end
end
