require 'rails-api'

class ApplicationController < ActionController::API
	include ActionController::Serialization

	skip_before_filter :verify_authenticity_token

  def index
    new_url, changed = correct_url!
    redirect_to new_url, status: :moved_permanently and return if changed

    html = bootstrap_index(params[:index_key])
    render text: html
  end

  def sitemap
    redirect_to 'https://s3.eu-central-1.amazonaws.com/www.klubi.si/sitemaps/sitemap.xml.gz'
  end

  def heartbeat
    render 'application/heartbeat', :formats=>[:html]
  end

private

  def supported_categories
    ENV['SUPPORTED_CATEGORIES'].split(',')
  end

  def correct_url!
    # Redirects:
    # /category/klub.slug -> /category/klub.url_slug
    # /klub.slug -> /category/klub.url_slug

    # TODO: remove this method after about 30 days, when google would
    # hopefully already register all the 301 and update its indices

    return '', false unless request.path_parameters[:path]

    path_parts = request.path_parameters[:path].split('/')
    supposed_category = path_parts.first

    changed = false

    if supported_categories.include? supposed_category
      # The format is /category/slug or /category/slug/uredi

      supposed_slug = path_parts[1]
      klub = Klub.where(slug: supposed_slug).first

      if klub
        new_url = request.original_url.sub(supposed_slug, klub.url_slug)
        return new_url, true
      end
    else
      # The format is /slug or /slug/uredi
      supposed_slug = path_parts.first

      klub = Klub.where(slug: supposed_slug).first
      if klub
        category = klub.categories.first
        new_url = request.original_url.sub(supposed_slug, "#{category}/#{klub.url_slug}")
        return new_url, true
      end
    end

    return '', false
  end

  def bootstrap_index(index_key)
    index_key ||= 'klubi:current-content'
    REDIS.get(index_key)
  end

end
