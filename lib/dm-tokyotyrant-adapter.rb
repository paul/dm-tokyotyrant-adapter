
require 'rubygems'
require 'dm-core'

require 'tokyotyrant'

module DataMapper::Adapters

  class TokyoTyrantAdapter < AbstractAdapter
    include TokyoTyrant

    VERSION = '0.1.0'.freeze
    DATABASE_TYPES = %w{hash btree fixed table}

    def initialize(name, options)
      super

      @options[:database] = @options[:path] # Who the hell is normalizing this?
      @options[:database] ||= :btree

      unless DATABASE_TYPES.include?(@options[:database].to_s)
        raise ":database option must be one of #{DATABASE_TYPES.inspect}. Defaults to btree"
      end

      @db = RDB::new
    end

    def create(records)
      db do |db|
        records.each do |record|
          model = record.model
          if identity_field = resource.model.identity_field(name)
            identity_field.set!(resource, rand(2**32))
          end
          records[resource.key] = resource.attributes
        end
      end
    end

    protected

    def db(&blk)
      # connect to the server
      if !@db.open(options[:hostname], options[:port])
        ecode = @db.ecode
        raise "Error opening connection to database: #{@db.errmsg(ecode)}"
      end

      yield @db

      if !@db.close
        ecode = @db.ecode
        raise "Error when closing connection: #{@db.errmsg(ecode)}"
      end
    end


  end

end
