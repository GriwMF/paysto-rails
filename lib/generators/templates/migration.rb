class CreatePaystoTables < ActiveRecord::Migration
  def change

    create_table :<%= Paysto.payment_class_name.underscore.pluralize %> do |t|
      t.float    :amount,                    default: 0.0
      t.float    :real_amount
      t.string   :gateway_code
      t.string   :gateway_payment_method
      t.timestamps
    end

    create_table :<%= Paysto.invoice_class_name.underscore.pluralize %> do |t|
      t.integer  :<%= Paysto.payment_class_name.underscore %>_id
      t.float    :amount,                    default: 0.0
      t.datetime :paid_at
      t.timestamps
    end
    add_index :<%= Paysto.invoice_class_name.underscore.pluralize %>, :<%= Paysto.payment_class_name.underscore %>_id

    create_table :<%= Paysto.invoice_notification_class_name.underscore.pluralize %> do |t|
      t.integer  :<%= Paysto.invoice_class_name.underscore %>_id
      t.text     :pay_data
      t.timestamps
    end
    add_index :<%= Paysto.invoice_notification_class_name.underscore.pluralize %>, :<%= Paysto.invoice_class_name.underscore %>_id

  end
end
