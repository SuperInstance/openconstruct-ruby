# frozen_string_literal: true

module OpenConstruct
  # In-process registry of available modules, filterable by domain.
  class ModuleRegistry
    BUILTIN_MODULES = [
      { id: "spectral-graph-core",   domain: "math",    description: "Spectral graph analysis engine" },
      { id: "plato-room",            domain: "physics",  description: "Platonic solid room builder" },
      { id: "llm-toolkit",           domain: "ai",      description: "LLM orchestration utilities" },
      { id: "linear-algebra",        domain: "math",    description: "Matrix & vector operations" },
      { id: "codegen-pipeline",      domain: "dev",     description: "Automated code generation pipeline" },
      { id: "data-ingest",           domain: "data",    description: "Data ingestion & ETL helpers" },
      { id: "topology-mapper",       domain: "math",    description: "Topological mapping & analysis" },
      { id: "physics-sim",           domain: "physics",  description: "Physics simulation framework" },
    ].freeze

    attr_reader :modules

    def initialize(modules: BUILTIN_MODULES)
      @modules = modules.map { |m| m.dup.freeze }.freeze
    end

    def list(domain: nil)
      return @modules.dup if domain.nil?

      @modules.select { |m| m[:domain] == domain.to_s }
    end

    def find(id)
      @modules.find { |m| m[:id] == id }
    end

    def validate!(ids)
      ids.each do |id|
        raise ArgumentError, "Unknown module: #{id}" unless find(id)
      end
    end
  end
end
