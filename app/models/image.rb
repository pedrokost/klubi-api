require 'pry' if Rails.env.test?

class Image
  include ActiveModel::Serialization

  attr_reader :id, :type, :thumbnail, :large

  def initialize(params)
    @id = params[:id]
    @type = params[:type]
    @thumbnail = params[:thumbnail]
    @large = params[:large]
  end

  def attributes
    {
      type: type,
      thumbnail: thumbnail,
      large: large
    }
  end
end
