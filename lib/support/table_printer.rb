# frozen_string_literal: true

module TablePrinter
  def self.print_row(data, columns, width = 80)
    return "" if data.empty?

    # Calculate column widths
    header_width = columns.map(&:length).max + 2
    value_width = width - header_width - 6  # Account for borders and padding
    
    # Print header
    StringIO.new.tap do |res|
      res.puts "┌" + "─" * (width - 2) + "┐"
      columns.each do |column|
        value = data[column] || ""
        # Truncate long values
        display_value = value[0...value_width-3]
        res.puts "│ %-#{header_width}s: %-#{value_width}s │" % [column, display_value]
      end
      res.puts "└" + "─" * (width - 2) + "┘"
    end.string
  end
end
