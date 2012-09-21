def load_qc
  c = ActiveRecord::Base.connection.instance_variable_get(:@config)
  cred = "#{c[:username]}:#{c[:password]}@" if c[:username] || c[:password]
  adapter = c[:adapter] == 'postgresql' ? 'postgres' : c[:adapter]
  ENV['QC_DATABASE_URL'] = "#{adapter}://#{cred}#{c.fetch(:host, 'localhost')}/#{c[:database]}"
  require 'queue_classic'
end

# FIXME: This requires pg9
class LoadQueueClassicFunctions < ActiveRecord::Migration
  def up
    # load_qc
    # QC::Queries.load_functions
  end

  def down
    # load_qc
    # QC::Queries.drop_functions
  end
end
