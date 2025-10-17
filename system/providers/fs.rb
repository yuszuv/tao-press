Application.register_provider(:fs) do
  prepare do
    require "csv"
    require "yaml"
    require "fileutils"
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

    register :markdown_writer do |path:, **opts, &block|
      File.open(path, "w", **opts) do |f|
        block.(f)
        f
      end
    end

    self
  end
end
