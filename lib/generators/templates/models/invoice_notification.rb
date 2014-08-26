class <%= Paysto.invoice_notification_class_name %> < ActiveRecord::Base
  # attr_accessible :<%= Paysto.invoice_class_name.underscore %>_id, :pay_data
  belongs_to :<%= Paysto.invoice_class_name.underscore %>, class_name: '<%= Paysto.invoice_class_name %>'
end