class <%= Paysto.invoice_class_name %> < ActiveRecord::Base
  # attr_accessible :<%= Paysto.payment_class_name.underscore %>_id,
  #                 :amount,
  #                 :paid_at

  belongs_to :<%= Paysto.payment_class_name.underscore %>, class_name: '<%= Paysto.payment_class_name %>'
  has_many :<%= Paysto.invoice_notification_class_name.underscore.pluralize %>, class_name: '<%= Paysto.invoice_notification_class_name %>', dependent: :destroy

  validates :amount, presence: true

  SUCCESS_STATES = {
    'paysto' => 'RES_PAID'
  }

  def notify(params, gateway)
    self.<%= Paysto.invoice_notification_class_name.underscore.pluralize %>.create(pay_data: info_by_gateway(params, gateway))
  end

  def need_to_be_paid?(gateway, payment_status, amount)
    !paid? && (payment_status == SUCCESS_STATES[gateway.to_s]) && (self.amount.to_f == amount.to_f)
  end

  def create_<%= Paysto.payment_class_name.underscore %>(payment_method, gateway_code, real_amount = nil)
    self.<%= Paysto.payment_class_name.underscore %> = <%= Paysto.payment_class_name %>.new(amount: self.amount,
                         real_amount: real_amount,
                        gateway_code: gateway_code,
              gateway_payment_method: payment_method)

    if self.<%= Paysto.payment_class_name.underscore %>.save
      self.paid_at = Time.zone.now
      self.save
    end
  end

  def paid?
    !!paid_at
  end

  private

  def info_by_gateway(_params, _gateway)
    _keys = case _gateway
            when :paysto
              ['PAYSTO_SUM', 'PAYSTO_INVOICE_ID', 'PAYSTO_SHOP_ID', 'PAYSTO_DESC', 'PAYSTO_TTL', 'PAYSTO_PAYMENT_ID', 'PAYSTO_REQUEST_MODE']
            else
              []
            end

    _keys.map do |_key|
      [_key, _params[_key.to_sym]].join(':')
    end.join(';')
  end

end