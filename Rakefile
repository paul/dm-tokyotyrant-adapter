
require 'rubygems'
require 'rake'

require 'lib/dm-tokyotyrant-adapter'

def with_gem(gemname, &blk)
  begin
    require gemname
    blk.call
  rescue LoadError => e
    puts "Failed to load gem #{gemname} because #{e}."
  end
end

with_gem 'echoe' do

  Echoe.new('dm-tokyotyrant-adapter',
            DataMapper::Adapters::TokyoTyrantAdapter::VERSION) do |p|
    
    p.author = "Paul Sadauskas"
    p.summary = "An Adapter for Datamapper for TokyoTyrant"
    p.url = "http://github.com/paul/dm-tokyotyrant-adapter"
    p.runtime_dependencies = ['dm-core', 'json']
    p.development_dependencies = ['rspec', 'echoe', 'yard']
  end
end

