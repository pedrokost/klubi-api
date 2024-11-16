class KlubMailer < ApplicationMailer

  def new_klub_mail(klub_id)
    @klub = Klub.unscoped.find(klub_id)
    @klub_data = @klub.to_json
    email = Rails.application.credentials.DEFAULT_EMAIL
    mail(to: email, subject: 'A new klub has been added for review')
  end

  def new_updates_mail(klub_id, editor)
    @klub = Klub.find(klub_id)
    @klub_name = @klub.name
    @editor_mail = editor
    email = Rails.application.credentials.DEFAULT_EMAIL
    mail(to: email, subject: "Updates submitted for '#{@klub.name}'")
  end

  def confirmation_for_pending_updates_mail(klub_id, editor_email, update_ids, new_branch_ids)

    @klub = Klub.unscoped.find(klub_id)
    @branches = [@klub] + @klub.branches
    @updates = Update.find(update_ids)

    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    subject = "🚶 Vaši popravki za #{@klub.name} ( ͡° ͜ʖ ͡°)"
    mail(from: from_email, to: editor_email, subject: subject)
  end

  def new_klub_thanks_mail(klub_id, editor_email)
    @klub = Klub.unscoped.find(klub_id)

    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    subject = "🚶 Hvala za dodani klub ( ͡° ͜ʖ ͡°)"
    mail(from: from_email, to: editor_email, subject: subject)
  end

  def confirmation_for_acceped_updates_mail(klub_id, editor_email, update_ids)
    @klub = Klub.unscoped.find(klub_id)

    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    subject = "🚶 Vaši popravki za #{@klub.name} so bili sprejeti (๑˃̵ᴗ˂̵)و"
    mail(from: from_email, to: editor_email, subject: subject)
  end

  def request_verify_klub_mail(klub_id, editor_email)
    @klub = Klub.unscoped.find(klub_id)
    from_email = Rails.application.credentials.DEFAULT_BOT_EMAIL
    bcc_email = Rails.application.credentials.DEFAULT_BCC_EMAIL
    subject = "🚶 Preverite podatke vašega kluba in pridobite nove člane!"

    mail(from: from_email, to: editor_email, subject: subject, bcc: bcc_email)
  end
end
