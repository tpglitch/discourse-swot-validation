# name: discourse-swot-validation
# about: Validates email sign-ups against the swot gem to check for academic email addresses
# version: 0.2
# authors: Tyler Kinney
# url: https://github.com/tpglitch/discourse-swot-validation

enabled_site_setting :swot_validation_enabled

gem 'swot', github: 'jetbrains/swot'

after_initialize do
  module ::SwotValidation
    class Engine < ::Rails::Engine
      engine_name 'swot_validation'
      isolate_namespace SwotValidation
    end
  end

  # Extend the existing UserValidator with swot validation
  require_dependency 'user_validator'

  class ::UserValidator
    def validate_email(email)
      super(email)
      if SiteSetting.swot_validation_enabled && Swot::is_academic?(email)
        # If the email is academic, we continue with the sign-up process
        return
      elsif SiteSetting.swot_validation_enabled
        # If the email is not academic and validation is enabled, add an error
        @errors.add(:email, I18n.t('user.email_is_not_academic'))
      end
    end
  end
end

# Add translations
register_locale_file "config/locales/server.en.yml", :en

# Configuration Settings
enabled_site_setting :swot_validation_enabled
