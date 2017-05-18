class StatisticnaRegija < ActiveRecord::Base
  has_many :obcinas

  def to_s
    name
  end
end
