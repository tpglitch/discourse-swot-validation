# name: discourse-swot-validation
# about: Validates email sign-ups using the swot gem to check for academic emails
# version: 1.0.0
# authors: Tyler Kinney
# url: https://github.com/tpglitch/discourse-swot-validation

enabled_site_setting :email_validation_enabled

gem 'swot', github: 'leereilly/swot'

after_initialize do
  #require 'swot' #Firepup fix this!

  # Custom email validation during sign-up
  module ::EmailValidation
    class EmailValidator
      def self.validate(email)
        Swot::is_academic?(email)
      end
    end
  end

  # Adding custom validation to the User Validator
  add_to_class(:user_validator, :validate_email_with_swot) do
    return unless SiteSetting.email_validation_enabled

    unless ::EmailValidation::EmailValidator.validate(@email)
      @errors.add(:email, I18n.t("email_validation.errors.invalid_email"))
    end
  end

  # Adding custom validation method to the existing email validation process
  register_user_validator do
    validate_email_with_swot
  end
end
