# OpenConstruct Ruby

Ruby client for [OpenConstruct](https://github.com/SuperInstance) — module-driven agent onboarding.

## Installation

```bash
gem install openconstruct
```

Or add to your Gemfile:

```ruby
gem "openconstruct", "~> 0.1.0"
```

## Usage

```ruby
require "openconstruct"

client = OpenConstruct::Client.new
client.start
client.declare_agent(name: "my-agent", model: "glm-5.1", capabilities: ["code_generation"])

# Browse available modules
modules = client.list_modules(domain: "math")
puts modules.map { |m| m[:id] }

# Select modules and generate config
client.select_modules("spectral-graph-core", "plato-room")
client.choose_interface("rest")
config = client.generate_config

puts config.to_json
```

## API

### `OpenConstruct::Client`

| Method | Phase | Description |
|--------|-------|-------------|
| `start` | 1 | Create a new onboarding session |
| `declare_agent(name:, model:, capabilities:)` | 2 | Describe the agent |
| `list_modules(domain: nil)` | — | Query available modules |
| `select_modules(*ids)` | 3 | Choose modules for the config |
| `choose_interface(iface)` | 4 | Pick REST, gRPC, WebSocket, or CLI |
| `generate_config` | 5 | Assemble the final `OnboardingConfig` |
| `reset` | — | Clear state for reuse |

### `OpenConstruct::ModuleRegistry`

Holds available modules. Filter by domain or look up by ID.

### `OpenConstruct::AgentIdentity`

Immutable struct: `name`, `model`, `capabilities`.

### `OpenConstruct::OnboardingConfig`

Immutable result with `session_id`, `agent`, `modules`, `interface`, `generated_at`. Supports `to_h` and `to_json`.

## Testing

```bash
ruby test/test_client.rb
```

## License

MIT
