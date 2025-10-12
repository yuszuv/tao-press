Application.register_provider(:fs) do
  prepare do
    require "csv"
  end

  start do
    csv_writer = ->(path:, **opts, &block) {
      CSV.open(path, 'w', **opts, &block)
    }
    register(:csv_writer, csv_writer)
  end
end
