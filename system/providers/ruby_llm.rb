require "dry/system"
require "ruby_llm"

Application.register_provider(:ruby_llm) do
  before :prepare do
    require "ruby_llm"
  end

  prepare do
    settings = target[:settings]

    RubyLLM.configure do |config|
      config.openai_api_key = settings.openai_api_key
    end

    register(:ruby_llm, RubyLLM)
  end
end
