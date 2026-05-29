# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/openconstruct"

class TestClientStart < Minitest::Test
  def test_start_creates_session
    client = OpenConstruct::Client.new
    result = client.start
    assert_kind_of OpenConstruct::Client, result
    refute_nil client.session_id
    assert_match(/\Aoc-[0-9a-f]{16}\z/, client.session_id)
  end

  def test_start_twice_raises
    client = OpenConstruct::Client.new
    client.start
    assert_raises(RuntimeError) { client.start }
  end
end

class TestDeclareAgent < Minitest::Test
  def setup
    @client = OpenConstruct::Client.new.start
  end

  def test_declare_agent
    @client.declare_agent(name: "my-agent", model: "glm-5.1", capabilities: ["code_generation"])
    agent = @client.agent
    assert_kind_of OpenConstruct::AgentIdentity, agent
    assert_equal "my-agent", agent.name
    assert_equal "glm-5.1", agent.model
    assert_equal ["code_generation"], agent.capabilities
  end

  def test_declare_agent_requires_name
    assert_raises(ArgumentError) { @client.declare_agent(name: "", model: "glm-5.1") }
  end

  def test_declare_agent_before_start_raises
    client = OpenConstruct::Client.new
    assert_raises(RuntimeError) { client.declare_agent(name: "x", model: "y") }
  end
end

class TestListModules < Minitest::Test
  def setup
    @client = OpenConstruct::Client.new.start
  end

  def test_list_all_modules
    modules = @client.list_modules
    assert !modules.empty?
  end

  def test_filter_by_domain
    math = @client.list_modules(domain: "math")
    assert math.length >= 2
    assert math.all? { |m| m[:domain] == "math" }
  end

  def test_filter_unknown_domain_returns_empty
    result = @client.list_modules(domain: "nonexistent")
    assert_empty result
  end
end

class TestSelectModules < Minitest::Test
  def setup
    @client = OpenConstruct::Client.new.start
  end

  def test_select_known_modules
    @client.select_modules("spectral-graph-core", "plato-room")
    assert_equal ["spectral-graph-core", "plato-room"], @client.selected_modules
  end

  def test_select_unknown_module_raises
    assert_raises(ArgumentError) { @client.select_modules("does-not-exist") }
  end

  def test_select_none_raises
    assert_raises(ArgumentError) { @client.select_modules }
  end
end

class TestChooseInterface < Minitest::Test
  def setup
    @client = OpenConstruct::Client.new.start
  end

  def test_choose_valid_interface
    @client.choose_interface("rest")
    assert_equal "rest", @client.interface
  end

  def test_choose_invalid_interface_raises
    assert_raises(ArgumentError) { @client.choose_interface("carrier_pigeon") }
  end
end

class TestGenerateConfig < Minitest::Test
  def setup
    @client = OpenConstruct::Client.new.start
    @client.declare_agent(name: "test-agent", model: "glm-5.1", capabilities: ["code_generation"])
    @client.select_modules("spectral-graph-core")
    @client.choose_interface("grpc")
  end

  def test_generate_config_returns_onboarding_config
    config = @client.generate_config
    assert_kind_of OpenConstruct::OnboardingConfig, config
    assert_equal @client.session_id, config.session_id
    assert_equal "test-agent", config.agent.name
    assert_equal ["spectral-graph-core"], config.modules
    assert_equal "grpc", config.interface
  end

  def test_config_has_timestamp
    config = @client.generate_config
    refute_nil config.generated_at
  end

  def test_config_to_h
    config = @client.generate_config
    h = config.to_h
    assert_kind_of Hash, h
    assert_equal @client.session_id, h[:session_id]
  end

  def test_config_to_json
    config = @client.generate_config
    json = config.to_json
    require "json"
    parsed = JSON.parse(json)
    assert_equal @client.session_id, parsed["session_id"]
  end
end

class TestFullLifecycle < Minitest::Test
  def test_full_lifecycle
    client = OpenConstruct::Client.new
    client.start
    client.declare_agent(name: "my-agent", model: "glm-5.1", capabilities: ["code_generation"])
    modules = client.list_modules(domain: "math")
    assert !modules.empty?
    ids = modules.map { |m| m[:id] }
    client.select_modules(*ids)
    client.choose_interface("rest")
    config = client.generate_config
    assert_kind_of OpenConstruct::OnboardingConfig, config
    assert_equal ids.sort, config.modules.sort
  end
end

class TestUniqueSessionId < Minitest::Test
  def test_unique_session_ids
    ids = 100.times.map do
      client = OpenConstruct::Client.new
      client.start
      client.session_id
    end
    assert_equal ids.uniq.length, ids.length
  end
end

class TestReset < Minitest::Test
  def test_reset_clears_state
    client = OpenConstruct::Client.new.start
    client.declare_agent(name: "a", model: "m")
    client.select_modules("spectral-graph-core")
    client.choose_interface("rest")
    client.reset
    assert_nil client.session_id
    assert_nil client.agent
    assert_empty client.selected_modules
    assert_nil client.interface
  end

  def test_reset_allows_new_session
    client = OpenConstruct::Client.new.start
    id1 = client.session_id
    client.reset.start
    id2 = client.session_id
    refute_equal id1, id2
  end
end
