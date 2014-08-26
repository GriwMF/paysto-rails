module Paysto
  require 'csv'

  mattr_accessor  :id,
                  :secret,
                  :description,
                  :urls,
                  :ips,
                  :tax,
                  :payment_class_name,
                  :invoice_class_name,
                  :invoice_notification_class_name

  class << self

    def setup
      yield self
    end

    def payment_class
      @@payment_class_name.constantize
    end

    def invoice_class
      @@invoice_class_name.constantize
    end

    def invoice_notification_class
      @@invoice_notification_class_name.constantize
    end

    def currencies
      https_request_to Paysto.urls[:currencies], base_params
    end

    def balance
      https_request_to Paysto.urls[:balance], base_params
    end

    def get_payments(from, to)
      p = { 'PAYSTO_SHOP_ID' => Paysto.id,
            'FROM'           => from.strftime('%Y%m%d%H%M'),
            'TO'             => to.strftime('%Y%m%d%H%M') }
      p.merge!('PAYSTO_MD5'  => generate_md5(p))

      res = https_request_to(Paysto.urls[:payments_list], p)
      CSV.parse(res)
    end

    def get_payment_type(invoice_id, time = Time.zone.now)
      _type = 'common'
      _payments = get_payments(time.utc - 30.minutes, time.utc + 5.minutes)
      if _payments.present?
        p = _payments.select{|_p| _p[2].eql?(invoice_id.to_s)}.first
        _type = p[7] if p
      end
      _type
    end

    def invoice_valid?(invoice)
      invoice && invoice.payment_id.blank? && invoice.paid_at.blank?
    end

    def ip_valid?(ip)
      Paysto.ips.include?(ip)
    end

    def md5_valid?(p)
      generate_md5(p.reject{|k,v| ['action', 'controller', 'PAYSTO_MD5'].include?(k)}) == p['PAYSTO_MD5']
    end

    def pay_till
      (Time.zone.now + 1.day + 1.minute).utc.strftime('%Y%m%d%H%M')
    end

    def real_amount(str)
      amount = str.to_f
      _tax = amount * Paysto.tax
      _tax = 10 if _tax < 10
      amount - _tax
    end

    private

    def generate_md5(p = {}, upcase = true)
      hash_str = p.to_a.sort_by{|pair| pair.first.downcase}.map{|pair| pair.join('=')}.join('&')
      md5 = Digest::MD5.hexdigest("#{hash_str}&#{Paysto.secret}")
      if upcase
        md5.upcase
      else
        md5
      end
    end

    def base_params
      p = { 'PAYSTO_SHOP_ID' => Paysto.id }
      p.merge!('PAYSTO_MD5'  => generate_md5(p))
    end

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