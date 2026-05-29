# frozen_string_literal: true

require_relative "openconstruct/client"
require_relative "openconstruct/registry"
require_relative "openconstruct/types"

# OpenConstruct — Ruby binding for module-driven agent onboarding.
#
# Usage:
#
#   client = OpenConstruct::Client.new
#   client.start
#   client.declare_agent(name: "my-agent", model: "glm-5.1", capabilities: ["code_generation"])
#   modules = client.list_modules(domain: "math")
#   client.select_modules("spectral-graph-core", "plato-room")
#   client.choose_interface("rest")
#   config = client.generate_config
#
module OpenConstruct
  VERSION = "0.1.0"
end
