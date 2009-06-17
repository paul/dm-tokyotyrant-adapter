
require 'rubygems'
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

require 'tokyotyrant'
require 'json'

module DataMapper::Adapters

  class TokyoTyrantAdapter < AbstractAdapter
    include TokyoTyrant

    VERSION = '0.1.0'.freeze
    DATABASE_TYPES = %w{hash btree fixed table}

    def initialize(name, options)
      super

      @hostname = @options[:hostname] || 'localhost'
      @port     = @options[:port]     || 1978

      unless DATABASE_TYPES.include?(@database.to_s)
        raise ":database option must be one of #{DATABASE_TYPES.inspect}. Defaults to btree"
      end

      @db = RDB::new
    end

    def db(&blk)
      # connect to the server
      if !@db.open(@hostname, @port)
        ecode = @db.ecode
        raise "Error opening connection to database: #{@db.errmsg(ecode)}"
      end

      result = yield @db

      if !@db.close
        ecode = @db.ecode
        raise ConnectError, @db.errmsg(ecode)
      end

      result
    end

    def create(resources)
      db do |db|
        resources.each do |resource|
          initialize_identity_field(resource, rand(2**32))
          save(db, key(resource), serialize(resource))
        end
      end
    end

    def read(query)
      model = query.model

      db do |db|
        keys = db.fwmkeys(model.to_s)
        records = []
        keys.each do |key|
          value = db.get(key)
          records << deserialize(value) if value
        end
        query.filter_records(records)
      end
    end

    def update(attributes, collection)
      attributes = attributes_as_fields(attributes)
      db do |db|
        collection.each do |resource|
          attributes = resource.attributes(:field).merge(attributes)
          save(db, key(resource), serialize(resource))
        end
      end
    end

    def delete(collection)
      db do |db|
        collection.each do |resource|
          db.delete(key(resource))
        end
      end
    end

    protected

    def key(resource)
      model = resource.model
      key = resource.key.join('/')
      "#{model}/#{key}"
    end

    def serialize(resource_or_attributes)
      if resource_or_attributes.is_a?(DataMapper::Resource)
        resource_or_attributes.attributes(:field)
      else
        resource_or_attributes
      end.to_json
    end

    def deserialize(string)
      JSON.parse(string)
    end

    def save(db, key, value)
      if !db.put(key, value)
        ecode = db.ecode
        raise WriteError, db.errmsg(ecode)
      end
    end

    class ConnectError < StandardError
    end

    class WriteError < StandardError
    end

    class ReadError < StandardError
    end

  end

end
