module Paysto
  require 'csv'

  mattr_accessor  :id,
                  :secret,
                  :description,
                  :urls,
                  :ips,
                  :tax,
                  :min_tax,
                  :expiration,
                  :payment_class_name,
                  :invoice_class_name,
                  :invoice_notification_class_name

  class << self

    # Configuring module.
    def setup
      yield self
    end

    # Payment class.
    def payment_class
      @@payment_class_name.constantize
    end

    # Invoice class.
    def invoice_class
      @@invoice_class_name.constantize
    end

    # InvoiceNotification class.
    def invoice_notification_class
      @@invoice_notification_class_name.constantize
    end

    # List of available pay methods according to your tariff plan.
    def currencies
      https_request_to @@urls[:currencies], base_params
    end

    # Your current balance in Paysto.
    def balance
      https_request_to @@urls[:balance], base_params
    end

    # Returns array of payments with details between dates.
    # +from+  –  from date.
    # +to+    –  to date.
    def get_payments(from, to)
      p = { 'PAYSTO_SHOP_ID' => @@id,
            'FROM'           => from.strftime('%Y%m%d%H%M'),
            'TO'             => to.strftime('%Y%m%d%H%M') }
      p.merge!('PAYSTO_MD5'  => generate_md5(p))

      res = https_request_to(@@urls[:payments_list], p)
      CSV.parse(res)
    end

    # Returns payment type or 'common' by default.
    # +invoice_id+  –  invoice ID of payment.
    # +time+        –  estimated payment execution time.
    def get_payment_type(invoice_id, time = Time.zone.now)
      _payments = get_payments(time.utc - 30.minutes, time.utc + 5.minutes)
      if _payments.present?
        p = _payments.select{|_p| _p[2].eql?(invoice_id.to_s)}.first
        _type = p[7] if p
      end
      _type || 'common'
    end

    # Check whether the invoice is valid.
    def invoice_valid?(invoice)
      invoice && invoice.send("#{@@payment_class_name.underscore}_id").blank? && invoice.paid_at.blank?
    end

    # Check whether the IP is permitted.
    def ip_valid?(ip)
      @@ips.include?(ip)
    end

    # Check whether the MD5 sign is valid.
    def md5_valid?(p)
      except_keys = ['action', 'controller', 'PAYSTO_MD5']
      generate_md5(p.reject{|k,v| except_keys.include?(k)}) == p['PAYSTO_MD5']
    end

    # Timestamp string in Paysto format for payments expiration.
    def pay_till
      (Time.zone.now + @@expiration).utc.strftime('%Y%m%d%H%M')
    end

    # Real income value without Paysto tax for any amount which you want to calculate.
    # +str+  –  amount string or numeric, does not matter.
    def real_amount(str)
      amount = str.to_f
      _tax = amount * @@tax
      _tax = @@min_tax if _tax < @@min_tax
      amount - _tax
    end

    private

    # Generating MD5 sign according with received params.
    def generate_md5(p = {}, upcase = true)
      hash_str = p.to_a.sort_by{|pair| pair.first.downcase}.map{|pair| pair.join('=')}.join('&')
      md5 = Digest::MD5.hexdigest("#{hash_str}&#{@@secret}")
      upcase ? md5.upcase : md5
    end

    # Base set of params for requests.
    def base_params
      p = { 'PAYSTO_SHOP_ID' => @@id }
      p.merge!('PAYSTO_MD5'  => generate_md5(p))
    end

    # Performing an HTTPS request.
    def https_request_to(url, params)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(params)
      session = Net::HTTP.new(uri.hostname, 443)
      session.use_ssl = true
      res = session.start do |http|
        http.request(req)
      end
      res.body.force_encoding('UTF-8')
    end

  end
end
