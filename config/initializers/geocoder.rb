Geocoder.configure(
  # geocoding options
  :timeout        => 20,           # geocoding service timeout (secs)
  :lookup         => :google,     # name of geocoding service (symbol)
  :language       => :sl,         # ISO-639 language code
  :use_https      => true,       # use HTTPS for lookup requests? (if supported)
  # :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
  # :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
  :api_key        => Rails.application.credentials.GOOGLE_GEOCODING_API_SERVER_KEY,         # API key for geocoding service
  # :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
  # :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

  # exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  # :always_raise => [],

  # calculation options
  :units          => :km,       # :km for kilometers or :mi for miles
  # :distances    => :linear    # :spherical or :linear
  :region         => :sl
)
