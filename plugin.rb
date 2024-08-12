# frozen_string_literal: true

enabled_site_setting :email_validator_enabled

after_initialize do
  module ::EmailValidator
    class Engine < ::Rails::Engine
      engine_name "email_validator"
      isolate_namespace EmailValidator
    end
  end

  require_dependency 'email_validator/email_checker'

  class ::Users::EmailValidator
    def self.can_signup?(email)
      response = EmailValidator::EmailChecker.is_academic?(email)
      response["isAcademic"]
    rescue => e
      Rails.logger.error("Email validation failed: #{e.message}")
      false
    end
  end

  DiscourseEvent.on(:before_validate_user) do |user|
    unless Users::EmailValidator.can_signup?(user.email)
      user.errors.add(:email, I18n.t("email_validator.not_academic"))
    end
  end
end
