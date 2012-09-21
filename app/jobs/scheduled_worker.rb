class ScheduledWorker
  @queue = :scheduled

  def self.perform frequency="daily"
    Rails.logger.info "This is an example of a scheduled resque job, runs #{ frequency }"
  end
end