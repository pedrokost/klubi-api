class Update < ActiveRecord::Base
  enum status: {
    unverified: 'unverified',
    accepted:   'accepted',
    rejected:   'rejected',
  }
  belongs_to :updatable, polymorphic: true
end
