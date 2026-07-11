require 'rails_helper'

RSpec.describe BootstrapIndexService do
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:memory_cache) { ActiveSupport::Cache::MemoryStore.new }

  subject(:service) { BootstrapIndexService.new(s3_client: s3) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_cache)
    BootstrapIndexService.last_good = nil
  end

  after do
    BootstrapIndexService.last_good = nil
  end

  describe "#fetch without a revision" do
    it "returns the active index.html from S3" do
      s3.stub_responses(:get_object, { body: '<html>current</html>' })

      expect(service.fetch).to eq '<html>current</html>'
    end

    it "requests the index/index.html object" do
      requested_keys = []
      s3.stub_responses(:get_object, lambda { |context|
        requested_keys << context.params[:key]
        { body: '<html></html>' }
      })

      service.fetch

      expect(requested_keys).to eq ['index/index.html']
    end

    it "caches the html" do
      s3.stub_responses(:get_object, { body: '<html>first</html>' })
      service.fetch

      s3.stub_responses(:get_object, { body: '<html>second</html>' })

      expect(BootstrapIndexService.new(s3_client: s3).fetch).to eq '<html>first</html>'
    end

    context "when S3 is unavailable" do
      before do
        s3.stub_responses(:get_object, 'ServiceUnavailable')
        allow(Raygun).to receive(:track_exception)
      end

      it "falls back to the last known good copy" do
        BootstrapIndexService.last_good = '<html>last good</html>'

        expect(service.fetch).to eq '<html>last good</html>'
      end

      it "falls back to the fallback file when no last known good copy exists" do
        allow(File).to receive(:read).with(BootstrapIndexService::FALLBACK_FILE)
          .and_return('<html>fallback</html>')

        expect(service.fetch).to eq '<html>fallback</html>'
      end

      it "reports the exception" do
        BootstrapIndexService.last_good = '<html></html>'
        service.fetch

        expect(Raygun).to have_received(:track_exception)
      end
    end
  end

  describe "#fetch with a revision" do
    it "returns that revision from S3, uncached" do
      requested_keys = []
      s3.stub_responses(:get_object, lambda { |context|
        requested_keys << context.params[:key]
        { body: '<html>rev</html>' }
      })

      expect(service.fetch('abc123')).to eq '<html>rev</html>'
      expect(requested_keys).to eq ['index/index.html:abc123']
      expect(memory_cache.read(BootstrapIndexService::CACHE_KEY)).to be_nil
    end

    it "rejects revisions with path characters" do
      expect { service.fetch('../../etc/passwd') }
        .to raise_error BootstrapIndexService::InvalidRevision
    end

    it "rejects the legacy klubi:<rev> format" do
      expect { service.fetch('klubi:abc123') }
        .to raise_error BootstrapIndexService::InvalidRevision
    end

    it "rejects overlong revisions" do
      expect { service.fetch('a' * 65) }
        .to raise_error BootstrapIndexService::InvalidRevision
    end
  end
end
