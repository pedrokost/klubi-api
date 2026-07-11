class BootstrapIndexService
  INDEX_KEY       = 'index/index.html'.freeze # matches ember-cli-deploy-s3-index prefix "index"
  REVISION_FORMAT = /\A[a-zA-Z0-9]{1,64}\z/
  CACHE_KEY       = 'bootstrap_index/current'.freeze
  CACHE_TTL       = 5.minutes
  FALLBACK_FILE   = Rails.root.join('public', 'fallback_index.html')

  class InvalidRevision < StandardError; end

  class << self
    # last-known-good copy per process, survives cache expiry during S3 outages
    attr_accessor :last_good
  end

  def initialize(s3_client: nil)
    @s3 = s3_client
  end

  def fetch(revision = nil)
    revision.present? ? fetch_revision(revision) : fetch_current
  end

  private

  def fetch_current
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
      get_object(INDEX_KEY).tap { |html| self.class.last_good = html }
    end
  rescue Aws::Errors::ServiceError, Seahorse::Client::NetworkingError => e
    Raygun.track_exception(e)
    self.class.last_good || File.read(FALLBACK_FILE)
  end

  def fetch_revision(revision)
    raise InvalidRevision unless revision.match?(REVISION_FORMAT)

    get_object("#{INDEX_KEY}:#{revision}")
  end

  def get_object(key)
    s3.get_object(bucket: bucket, key: key).body.read
  end

  def s3
    @s3 ||= Aws::S3::Client.new(
      region: Rails.application.credentials.AWS_REGION,
      access_key_id: Rails.application.credentials.AWS_ACCESS_KEY_ID,
      secret_access_key: Rails.application.credentials.AWS_SECRET_ACCESS_KEY
    )
  end

  def bucket
    Rails.application.credentials.AWS_BUCKET
  end
end
