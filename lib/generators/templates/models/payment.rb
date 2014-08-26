class <%= Paysto.payment_class_name %> < ActiveRecord::Base
  # attr_accessible :amount,
  #                 :real_amount,
  #                 :gateway_code,
  #                 :gateway_payment_method

  has_one :<%= Paysto.invoice_class_name.underscore %>, class_name: '<%= Paysto.invoice_class_name %>', dependent: :destroy

  validates :amount, presence: true
  validates :amount, exclusion: { in: [0] }, allow_nil: false
end