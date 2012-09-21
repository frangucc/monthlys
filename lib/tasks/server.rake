namespace :server do
  desc "copy redis config to the server"
  task :redis_init do
    system "sudo cp #{ Rails.root }/config/server/redis.conf /etc"
    system "sudo cp #{ Rails.root }/config/server/redis-server /etc/init.d"
    system "sudo useradd -s /bin/false redis"
    system "sudo /etc/init.d/redis-server restart"
  end
end