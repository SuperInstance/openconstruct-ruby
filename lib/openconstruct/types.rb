# frozen_string_literal: true

module OpenConstruct
  # Immutable struct describing an agent that will use the onboarding config.
  AgentIdentity = Struct.new(:name, :model, :capabilities, keyword_init: true) do
    def to_h
      { name: name, model: model, capabilities: capabilities }
    end
  end

  # Immutable snapshot of the assembled onboarding configuration.
  class OnboardingConfig
    attr_reader :session_id, :agent, :modules, :interface, :generated_at

    def initialize(session_id:, agent:, modules:, interface:, generated_at: Time.now)
      @session_id    = session_id
      @agent         = agent
      @modules       = Array(modules).map(&:freeze).freeze
      @interface     = interface
      @generated_at  = generated_at
      freeze
    end

    def to_h
      {
        session_id:    session_id,
        agent:         agent.to_h,
        modules:       modules,
        interface:     interface,
        generated_at:  generated_at.to_s
      }
    end

    def to_json(*_args)
      require "json"
      JSON.pretty_generate(to_h)
    end
  end
end
