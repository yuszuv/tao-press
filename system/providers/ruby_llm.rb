# frozen_string_literal: true
Application.register_provider(:ruby_llm) do
  prepare do
    require "ruby_llm"
  end

  start do
    settings = target[:settings]

    RubyLLM.configure do |config|
      config.openai_api_key = settings.openai_api_key
    end

    register(:ruby_llm, RubyLLM)
  end
end
