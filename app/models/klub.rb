class Klub < ActiveRecord::Base
	before_save :update_slug
	before_save :update_complete

	validates :slug, uniqueness: true
	validates :name, presence: true

	default_scope { where(complete: true) }

private
	def update_complete
		self.complete = !(self.name.blank? || self.latitude.nil? || self.longitude.nil?)
		nil
	end

	def generate_slug(slug)
		slug + Randgen.last_name
	end

	def update_slug

		slug = self.name.gsub(' ', '-').downcase

		trySlug = slug
		while slug_taken(trySlug)
			trySlug = generate_slug(slug)
		end

		self.slug = trySlug
		nil
	end


	def slug_taken(slug)
		klub = Klub.unscoped.where(slug: slug).first
		return false unless klub
		return false if klub.id == self.id
		true
	end
end
