# config.ru
require "stringio"
require "dry/monads"
require "web_pipe"
require "web_pipe/plugs/config"

require_relative "./system/container"
require_relative "./system/import"

WebPipe.load_extensions(:container)

class TaoPressServer
  include WebPipe
  include Dry::Monads[:result]

  plug :config, WebPipe::Plugs::Config.(
    container: Application
  )
  plug :csv
  plug :send_file


  private

  def csv(conn)
    conn.add_response_header('Content-Type', 'text/csv; charset=utf-8')
  end

  def greet(conn)
    conn.set_response_body("<h1>Hello World!</h1>")
  end

  def send_file(conn)
    csv = StringIO.new.tap do |f|
      conn.container["commands.export_news"].(path: f)
    end

    conn.set_response_body(csv.string)
  end
end

Application.finalize!

run TaoPressServer.new
