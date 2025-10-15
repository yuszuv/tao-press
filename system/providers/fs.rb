Application.register_provider(:fs) do
  prepare do
    require "csv"
  end

  start do
    register :csv_reader do |path, &block|
      CSV.readlines(path).then do |headers, *rows|
        rows
          .map(&headers.method(:zip))
          .map(&:to_h)
          .each do |row|
            block.(row)
          end
      end
    end

    register :csv_writer do |path:, **opts, &block|
      CSV.open(path, 'w', **opts, &block)
    end

    self
  end
end
