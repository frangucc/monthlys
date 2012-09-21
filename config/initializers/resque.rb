Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
Resque.redis = $redis = Redis.new(:host => config['host'], :port => config['port'], :password => config["password"])

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

class CanAccessResque
  def self.matches?(request)
  	return true
  	# TODO: fix this
    current_user = request.env['warden'].user
    return false if current_user.blank?
    Ability.new(current_user).can? :manage, Resque
  end
end
