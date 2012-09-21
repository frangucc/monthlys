class SlugGeneratorService

  def initialize(raw_slug)
    @raw_slug = raw_slug
  end

  def generate_slug(&block)
    @slug_exists = block
    slug = sanitize_slug(@raw_slug)

    # Append "-number" to the slug until it's unique
    if slug_exists?(slug)
      index = 1
      slug_with_number = "#{slug}-#{index}"
      while slug_exists?(slug_with_number)
        index += 1
        slug_with_number = "#{slug}-#{index}"
      end
      slug = slug_with_number
    end

    slug
  end

  def sanitize_slug(dirty_slug)
    slug = dirty_slug.strip.downcase

    # blow away apostrophes
    slug.gsub! /['`]/, ''

    # @ --> at, and & --> and
    slug.gsub! /\s*@\s*/, ' at '
    slug.gsub! /\s*&\s*/, ' and '

    # replace all non alphanumeric, underscore or periods
    slug.gsub! /\s*[^A-Za-z0-9\-]\s*/, '-'

    # convert double underscores to single
    slug.gsub! /\-+/, '-'

    # strip off leading/trailing underscore
    slug.gsub! /\A[\-\.]+|[\-\.]+\z/, ''

    slug
  end

  def slug_exists?(slug)
    @slug_exists.call(slug)
  end
end
