require File.dirname(__FILE__) + '/spec_helper'

require 'dm-core/spec/adapter_shared_spec'

describe DataMapper::Adapters::TokyoTyrantAdapter do
  before :all do
    @adapter = DataMapper.setup(:default, :adapter   => 'tokyo_tyrant',
                                          :hostname  => 'localhost',
                                          :port      => 1978)
  end

  it_should_behave_like 'An Adapter'

end
