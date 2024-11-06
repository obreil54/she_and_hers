class UserMailer < ApplicationMailer
  default from: 'no-reply@shersstudios.com'

  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: 'Welcome to Shers Studios!',
      reply_to: 'shers.studios@outlook.com'
    )
  end
end
