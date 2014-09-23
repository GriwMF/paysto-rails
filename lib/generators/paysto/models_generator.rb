require 'rails/generators'
require 'rails/generators/migration'

module Paysto
  class ModelsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../../templates', __FILE__)

    # Migration timestamp.
    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.new.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    # Create migration with required tables.
    def create_migration_file
      migration_template 'migration.rb', 'db/migrate/create_paysto_tables.rb'
    end

    # Render configured models.
    def copy_models
      template 'models/payment.rb',              "app/models/#{Paysto.payment_class_name.underscore}.rb"
      template 'models/invoice.rb',              "app/models/#{Paysto.invoice_class_name.underscore}.rb"
      template 'models/invoice_notification.rb', "app/models/#{Paysto.invoice_notification_class_name.underscore}.rb"
    end
  end
end
