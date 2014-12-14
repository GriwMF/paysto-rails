Paysto.setup do |config|

  # === Put your real Paysto credentials here.
  config.id          = 'SECRET-ID'
  config.secret      = 'SECRET-KEY'
  config.description = 'CUSTOM-DESCRIPTION-FOR-PAYMENTS'

  # === Paysto URLs.
  config.urls = {
    payment:        'https://paysto.com/ru/pay',
    currencies:     'https://paysto.com/api/Common/Currency',
    balance:        'https://paysto.com/api/Common/Balance',
    payments_list:  'https://paysto.com/api/Payment/GetList'
  }

  # === Paysto server IPs.
  config.ips = [
    '66.226.72.66',
    '66.226.74.225',
    '66.226.74.226',
    '66.226.74.227',
    '66.226.74.228',
    '23.102.21.72',
    '23.102.17.162',
    '137.135.207.41'
  ]

  # === Payments tax of your tariff plan in Paysto. Default onlineMerchant "All inclusive" is 5%.
  config.tax = 0.05

  # === Minimal Paysto tax for each payment. Default: 10.
  config.min_tax = 10

  # === Payments expiration. Default: 1.day.
  config.expiration = 1.day

  # === Customize model names as you want before they are will be generated.
  config.payment_class_name              = 'Payment'
  config.invoice_class_name              = 'Invoice'
  config.invoice_notification_class_name = 'InvoiceNotification'

end