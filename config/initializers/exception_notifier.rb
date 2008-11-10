admin_email = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV]['admin_email']
ExceptionNotifier.exception_recipients = admin_email