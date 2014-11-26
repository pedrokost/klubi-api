class Klub < ActiveRecord::Base
	before_save :update_slug

	validates :slug, uniqueness: true
	validates :name, presence: true
	
private
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
	end


	def slug_taken(slug)
		klub = Klub.where(slug: slug).first
		return false unless klub
		return false if klub.id == self.id
		true
	end
end
