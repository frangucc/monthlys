module MP
  module SinatraHelpers
    module Gravatar
      include MP::SinatraHelpers::AppContext

      DEFAULT_AVATAR = '/mp/img/default_merchant.png'
      DEFAULT_SIZE = 80

      def gravatar(email, size = DEFAULT_SIZE, default = DEFAULT_AVATAR)
        return default if email.blank?

        email = email.strip.downcase
        url = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?"

        args = { _t: Time.now.to_i, s: size }
        req = appcontext.request
        args[:d] = "#{req.scheme}://#{req.host_with_port}#{default}"

        url + Rack::Utils.build_query(args)
      end
    end
  end
end
