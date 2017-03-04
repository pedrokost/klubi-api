# Preview all emails at http://localhost:3200/rails/mailers/
class KlubMailerPreview < ActionMailer::Preview

  def new_updates_mail
    klub = Klub.last
    KlubMailer.new_updates_mail(klub.id, 'joe@doe.com')
  end

  def confirmation_for_pending_updates_mail
    updates = Update.all[1..10]
    branch_updates = Update.where(field: 'address').all[1..2]
    deleted_branches = [Klub.first]

    klub = updates[0].updatable
    editor = 'you@me.com'
    KlubMailer.confirmation_for_pending_updates_mail(klub.id, editor, updates.map(&:id), branch_updates.map(&:id), deleted_branches.map(&:id))
  end

  def new_klub_thanks_mail
    klub = Klub.first
    editor = 'json@brad.com'
    KlubMailer.new_klub_thanks_mail(klub.id, editor)
  end

  def confirmation_for_acceped_updates_mail
    updates = Update.all[3..5]
    klub = updates[0].updatable
    klub.branches << Klub.last
    editor = 'you@me.com'

    KlubMailer.confirmation_for_acceped_updates_mail(klub.id, editor, updates.map(&:id))
  end

  def request_verify_klub_mail
    klub = Klub.first
    klub.branches << Klub.last
    editor = 'owner@klub.com'
    KlubMailer.request_verify_klub_mail(klub.id, editor)
  end
end
