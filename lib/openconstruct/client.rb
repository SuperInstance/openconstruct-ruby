# frozen_string_literal: true

require "securerandom"
require_relative "types"
require_relative "registry"

module OpenConstruct
  # Thin client implementing the OpenConstruct phase-flow:
  #   start → declare_agent → list_modules → select_modules →
  #   choose_interface → generate_config
  class Client
    INTERFACES = %w[rest grpc websocket cli].freeze

    attr_reader :session_id, :agent, :selected_modules, :interface, :registry

    def initialize(registry: ModuleRegistry.new)
      @registry         = registry
      @session_id       = nil
      @agent            = nil
      @selected_modules = []
      @interface        = nil
      @started          = false
    end

    # Phase 1 — initialise a new onboarding session.
    def start
      raise "Session already started" if @started

      @session_id = "oc-#{SecureRandom.hex(8)}"
      @started    = true
      self
    end

    # Phase 2 — describe the agent that will consume the config.
    def declare_agent(name:, model:, capabilities: [])
      ensure_started!
      raise ArgumentError, "name is required" if name.nil? || name.empty?
      raise ArgumentError, "model is required" if model.nil? || model.empty?

      @agent = AgentIdentity.new(
        name:         name,
        model:        model,
        capabilities: Array(capabilities).map(&:to_s)
      )
      self
    end

    # Query available modules, optionally filtered by domain.
    def list_modules(domain: nil)
      ensure_started!
      registry.list(domain: domain)
    end

    # Phase 3 — pick one or more modules for the configuration.
    def select_modules(*ids)
      ensure_started!
      raise ArgumentError, "At least one module is required" if ids.empty?

      registry.validate!(ids)
      @selected_modules = ids.map(&:to_s)
      self
    end

    # Phase 4 — choose the communication interface.
    def choose_interface(iface)
      ensure_started!
      unless INTERFACES.include?(iface.to_s)
        raise ArgumentError, "Unsupported interface: #{iface}. Supported: #{INTERFACES.join(', ')}"
      end

      @interface = iface.to_s
      self
    end

    # Phase 5 — assemble and return the final onboarding configuration.
    def generate_config
      ensure_started!
      raise "Agent not declared" unless @agent
      raise "No modules selected" if @selected_modules.empty?
      raise "Interface not chosen" unless @interface

      OnboardingConfig.new(
        session_id: @session_id,
        agent:      @agent,
        modules:    @selected_modules,
        interface:  @interface
      )
    end

    # Reset the client so it can be reused.
    def reset
      @session_id       = nil
      @agent            = nil
      @selected_modules = []
      @interface        = nil
      @started          = false
      self
    end

    private

    def ensure_started!
      raise "Session not started. Call #start first." unless @started
    end
  end
end
