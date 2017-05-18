class Obcina < ActiveRecord::Base
  belongs_to :statisticna_regija, touch: true

  def to_s
    name
  end
end
