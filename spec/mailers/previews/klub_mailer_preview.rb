# Preview all emails at http://localhost:3000/rails/mailers/update
class KlubMailerPreview < ActionMailer::Preview
  def confirmation_for_pending_updates_mail
    updates = Update.all[1..3]
    klub = updates[0].updatable
    editor = 'you@me.com'
    KlubMailer.confirmation_for_pending_updates_mail(klub.id, editor, updates.map(&:id))
  end
end
