require File.dirname(__FILE__) + '/spec_helper'

describe DataMapper::Adapters::TokyoTyrantAdapter do
  before :all do
    @adapter = DataMapper.setup(:default, :adapter   => 'tokyo_tyrant',
                                          :hostname  => 'localhost',
                                          :port      => 1978)

  end

  describe 'initialization' do

    it 'should connect' do
      @adapter.should be_instance_of(DataMapper::Adapters::TokyoTyrantAdapter)
      @adapter.options[:hostname].should == 'localhost'
      @adapter.options[:port].should ==     1978
    end

  end

  describe 'errors' do

    it 'should raise a runtime error if unsupported database type' do
      lambda { 
      DataMapper.setup(:bad_port, :adapter => 'tokyo_tyrant',
                                  :hostname => 'localhost',
                                  :port     => 59000,
                                  :database => :nodb)
      }.should raise_error(RuntimeError)
    end

    it 'should raise a runtime error if it cant connect' do
      adapter = DataMapper.setup(:bad_port, :adapter => 'tokyo_tyrant',
                                            :hostname => 'localhost',
                                            :port     => 59000)

      lambda { 
        adapter.db { }
      }.should raise_error(RuntimeError)
    end

  end

end
