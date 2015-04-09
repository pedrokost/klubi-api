class KlubMailer < ApplicationMailer

  def new_klub_mail(klub_data)
    @klub_data = klub_data
    email = ENV['DEFAULT_EMAIL']
    mail(to: email, subject: 'A new klub has been added for review')
  end
end
