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

  def self.open(path, &block)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    CSV.open(path, 'w', **OPTS, &block)
  end

  # def call(file, row)
  #   file << row
  # end

  # def to_proc
  #   method(:call).to_proc
  # end
end
