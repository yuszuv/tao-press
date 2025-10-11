require "csv"

class CSVWriter
  HEADERS = %i[
    title
    subheadline
    excerpt
  ].freeze

  OPTS = {
    write_headers: true,
    headers: HEADERS,
    force_quotes: true
  }.freeze

  def self.build
    CSV.open('users.csv', 'w', **OPTS)
  end

  def call(file, row)
    file << row
  end

  def to_proc
    method(:call).to_proc
  end
end
