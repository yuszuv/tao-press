class CSVWriter
  OPTS = {
    write_headers: true,
    headers: Serializers::CSVSerializer::HEADERS,
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
