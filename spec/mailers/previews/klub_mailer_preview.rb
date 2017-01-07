# Preview all emails at http://localhost:3200/rails/mailers/
class KlubMailerPreview < ActionMailer::Preview
  def confirmation_for_pending_updates_mail
    updates = Update.all[1..3]
    klub = updates[0].updatable
    editor = 'you@me.com'
    KlubMailer.confirmation_for_pending_updates_mail(klub.id, editor, updates.map(&:id))
  end

  def new_klub_thanks_mail
    klub = Klub.first
    editor = 'json@brad.com'
    KlubMailer.new_klub_thanks_mail(klub.id, editor)
  end

  def confirmation_for_acceped_updates_mail
    updates = Update.all[3..5]
    klub = updates[0].updatable
    editor = 'you@me.com'

    KlubMailer.confirmation_for_acceped_updates_mail(klub.id, editor, updates.map(&:id))
  end

  def request_verify_klub_mail
    klub = Klub.first
    editor = 'owner@klub.com'
    KlubMailer.request_verify_klub_mail(klub.id, editor)
  end
end
