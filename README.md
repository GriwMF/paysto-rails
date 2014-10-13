![paysto-rails logo](https://raw.github.com/fbandrey/paysto-rails/master/paysto-rails.png)

[![Gem Version](https://badge.fury.io/rb/paysto-rails.svg)](http://badge.fury.io/rb/paysto-rails)
[![Code Climate](https://codeclimate.com/github/fbandrey/paysto-rails/badges/gpa.svg)](https://codeclimate.com/github/fbandrey/paysto-rails)
[![Dependency Status](https://gemnasium.com/fbandrey/paysto-rails.svg)](https://gemnasium.com/fbandrey/paysto-rails)
[![security](https://hakiri.io/github/fbandrey/paysto-rails/master.svg)](https://hakiri.io/github/fbandrey/paysto-rails/master)
[![Inline docs](http://inch-ci.org/github/fbandrey/paysto-rails.png?branch=master)](http://inch-ci.org/github/fbandrey/paysto-rails)

This is first implementation for passing payments through [Paysto](https://paysto.com) gateway. It works only with «[onlineMerchant](https://paysto.com/ru/products/onlineMerchant)».

Check demo shop in action: [www.paysto.tk](http://www.paysto.tk/). And source code [here](http://github.com/fbandrey/paysto-demo).

## Installation

Add this line to your application's Gemfile:

    gem 'paysto-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paysto-rails

## Setup

After installation run this command:
```
rails generate paysto:install
```

It will create files for you:
```
  create  config/initializers/paysto.rb
  create  config/locales/paysto.en.yml
  create  config/locales/paysto.ru.yml
  create  app/controllers/paysto_controller.rb
```
and extend your routes with:
```
  namespace :paysto do
    post :success, :fail, :check, :callback
    get  :fail
  end
```

Right now you may configure model names in ```config/initializers/paysto.rb``` file for payments, invoices and their notifications. By default they are ```Payment```, ```Invoice``` and ```InvoiceNotification``` respectively.

Then run this command:
```
rails generate paysto:models
```
It will create your models and migration:

```
  create  db/migrate/20140101000000_create_paysto_tables.rb
  create  app/models/payment.rb
  create  app/models/invoice.rb
  create  app/models/invoice_notification.rb
```

In the simple case only what you should to do:

1. Put your real credentials in ```config/initializers/paysto.rb``` as well
2. Run ```rake db:migrate```

That's all.

## Usage

You have 3 models and 1 controller now if you did everything right before. Check models and extend them with logic or associations, which you need in your application.

Controller by default [extended with concern](https://github.com/fbandrey/paysto-rails/blob/master/lib/paysto/controller.rb) and contains all necessary methods:
```
class PaystoController < ApplicationController
  include Paysto::Controller
end
```
But you may override methods as you want. For example, if you want to redirect user to custom URL when payment is passed:
```
class PaystoController < ApplicationController
  include Paysto::Controller
  
  def success
    flash[:success] = I18n.t('paysto.success')
    redirect_to any_custom_payments_path
  end
end
```

Also you can customize [check](https://github.com/fbandrey/paysto-rails/blob/master/lib/paysto/controller.rb#L12) or [callback](https://github.com/fbandrey/paysto-rails/blob/master/lib/paysto/controller.rb#L23) methods using Paysto module as you want, but do it only if you know what's going on there.

Check [payment workflow](https://github.com/fbandrey/paysto-rails/wiki/Payment-workflow) wiki for more information.

#### Paysto methods

```Paysto.balance``` – current balance in Paysto.

```Paysto.currencies``` – available pay methods.

```Paysto.get_payments(from_date, to_date)``` – payments list between dates.

```Paysto.get_payment_type(invoice.id)``` – pay method for ```Invoice```.

```Paysto.invoice_valid?(invoice)``` – check whether the invoice is valid.

```Paysto.ip_valid?(request.remote_ip)``` – check whether the IP is permitted.

```Paysto.md5_valid?(params)``` – check whether the MD5 sign is valid.

```Paysto.pay_till``` – timestamp string for payment expiration in Paysto format.

```Paysto.real_amount(amount)``` – real income amount without Paysto tax.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
