# OpenConstruct Ruby — Gem for Agent Onboarding

Ruby client for [OpenConstruct](https://github.com/SuperInstance/OpenConstruct). Idiomatic Ruby with method-chaining-friendly API.

## What This Gives You

- **5-phase onboarding** — `start` → `declare_agent` → `select_modules` → `choose_interface` → `generate_config`
- **Module registry** — filter by domain, lookup by ID
- **Immutable identity** — `AgentIdentity` struct
- **JSON output** — `OnboardingConfig#to_json` for downstream consumption

## Quick Start

```ruby
require "openconstruct"

client = OpenConstruct::Client.new
client.start
client.declare_agent(name: "my-agent", model: "glm-5.1", capabilities: ["code_generation"])

modules = client.list_modules(domain: "math")
client.select_modules("spectral-graph-core", "plato-room")
client.choose_interface("rest")

config = client.generate_config
puts config.to_json
```

## Installation

```bash
gem install openconstruct
```

Or in your Gemfile:

```ruby
gem "openconstruct", "~> 0.1.0"
```

## API

| Method | Phase | Description |
|--------|-------|-------------|
| `start` | 1 | Create a new onboarding session |
| `declare_agent(name:, model:, capabilities:)` | 2 | Describe the agent |
| `list_modules(domain: nil)` | — | Query available modules |
| `select_modules(*ids)` | 3 | Choose modules for the config |
| `choose_interface(iface)` | 4 | Pick REST, gRPC, WebSocket, or CLI |
| `generate_config` | 5 | Assemble the final `OnboardingConfig` |
| `reset` | — | Clear state for reuse |

## Testing

```bash
bundle exec rake test
```

## License

MIT
