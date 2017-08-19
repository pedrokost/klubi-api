class StatisticnaRegija < ApplicationRecord
  has_many :obcinas

  def to_s
    name
  end
end
