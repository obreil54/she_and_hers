class OrderMailer < ApplicationMailer
  default from: 'no-reply@shersstudios.com'

  def order_placed_email(order)
    @order = order
    mail(
      to: @order.email,
      subject: 'Your Order has been Placed!',
      reply_to: 'shers.studios@outlook.com'
    )
  end

  def order_shipped_email(order)
    @order = order
    mail(
      to: @order.email,
      subject: 'Your Order has Shipped!',
      reply_to: 'shers.studios@outlook.com'
    )
  end

  def order_delivered_email(order)
    @order = order
    mail(
      to: @order.email,
      subject: 'Your Order has been Delivered!',
      reply_to: 'shers.studios@outlook.com'
    )
  end
end
