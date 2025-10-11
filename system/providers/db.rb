Application.register_provider(:db) do
  prepare do
    target.start :settings
    target.start :logger

    require "sequel"

    url = target[:settings].database_url

    raise "DATABASE_URL missing" unless url

    db = Sequel.connect(url)
    
    # Enable SQL logging if SQL_LOGGING environment variable is set to true
    if target[:settings].logger_level == :debug
      db.loggers << target[:logger]
      db.sql_log_level = :info
    end

    # MySQL-Option: Ergebnisse standardmäßig als Strings, keine impliziten Symbol-Keys erzwingen
    # db.extension :date_arithmetic

    register(:db, db)
  end

  start do
    # container[:database].establish_connection
  end

  stop do
    # container[:database].close_connection
  end
end
