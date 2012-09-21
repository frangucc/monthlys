class EmailRecipient < ActiveRecord::Base

  belongs_to :emailable, polymorphic: true

  serialize :profile_attributes, Hash

  validates_presence_of :emailable_type, :emailable_id

  after_commit :schedule_api_update
  before_save :sync_with_emailable

  def exact_target_attributes
    profile_attributes
  end

  def exists_in_api?
    exact_target_id.present?
  end

  def api_action
    (exists_in_api?)? 'update' : 'create'
  end

  def schedule_api_update
    if Rails.configuration.exact_target_enabled
      Resque.enqueue(Monthly::ExactTarget::Worker, :update_api, 'EmailRecipient', self.id)
    end
  end

  def api_client
    @api_client ||= Monthly::ExactTarget::Client.new(source: self)
  end

  def sync_with_api
    api_client.send("#{api_action}_subscriber")
  end

  def sync_with_emailable
    self.email = self.emailable.email
    self.profile_attributes = self.subscriber_attributes
  end

  def subscriber_attributes
    emailable.exact_target_attributes
  end
end
