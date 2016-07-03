class KlubMailer < ApplicationMailer

  def new_klub_mail(klub_id)
    @klub = Klub.unscoped.find(klub_id)
    @klub_data = @klub.to_json
    email = ENV['DEFAULT_EMAIL']
    mail(to: email, subject: 'A new klub has been added for review')
  end

  def new_updates_mail(klub_name, updates)
    @klub_name = klub_name
    @updates = updates
    @editor_mail = updates.first.try(:editor_email)
    email = ENV['DEFAULT_EMAIL']
    mail(to: email, subject: "Updates submitted for '#{klub_name}'")
  end
end
