ENV['QC_DATABASE_URL'] = MP::Conf::QC_DATABASE_URL
ENV['QC_LOG_LEVEL'] = MP::Conf::QC_LOG_LEVEL.to_s
require 'queue_classic'

module MP
  module Jobs
    require mp_path('mp/jobs/admin')
    require mp_path('mp/jobs/merchants')
  end
end
