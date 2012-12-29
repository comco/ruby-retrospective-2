module RegexConstants
  TLD = /[[:alpha:]]{2,3}(\.[[:alpha:]]{2})?/
  DOMAIN_NAME = /[[:alnum:]]|[[:alnum:]][[:alnum:]-]{,60}[[:alnum:]]/
  SUBDOMAIN = /#{DOMAIN_NAME}/
  DOMAIN = /#{DOMAIN_NAME}\.#{TLD}/
  HOSTNAME = /(#{SUBDOMAIN}\.)*#{DOMAIN}/
  USERNAME = /[[:alnum:]][\w+.-]{,200}/
  EMAIL = /(?<username>#{USERNAME})@(?<hostname>#{HOSTNAME})/

  INTERNATIONAL_CODE = /[1-9]\d{,2}/
  INTERNATIONAL_PREFIX = /(00|\+)#{INTERNATIONAL_CODE}/
  PHONE_PREFIX = /0|#{INTERNATIONAL_PREFIX}/
  PHONE_DELIMITERS = /[ ()-]/
  PHONE_BODY = /\d(#{PHONE_DELIMITERS}{,2}\d){5,10}/
  PHONE = /#{PHONE_PREFIX}#{PHONE_DELIMITERS}*#{PHONE_BODY}/
  INTERNATIONAL_PHONE = /(?<prefix>#{INTERNATIONAL_PREFIX})#{PHONE_DELIMITERS}*#{PHONE_BODY}/

  BYTE = /0|1\d\d|2[0-4]\d|25[0-5]|[1-9]\d?/
  IP_ADDRESS = /#{BYTE}(\.#{BYTE}){3}/

  INTEGER = /-?(0|[1-9]\d*)/
  NUMBER = /#{INTEGER}(\.\d+)?/

  DATE = /\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2]\d|3[0-1])/
  TIME = /([0-1]\d|2[0-3]):(?<six>[0-5]\d):\g<six>/
  DATE_TIME = /#{DATE}[ T](#{TIME})/
end

class Validations
  class << self
    include RegexConstants

    def exact?(regex, value)
      not (value =~ /\A#{regex}\z/).nil?
    end

    def email?(value)
      exact?(EMAIL, value)
    end

    def phone?(value)
      exact?(PHONE, value)
    end

    def hostname?(value)
      exact?(HOSTNAME, value)
    end

    def ip_address?(value)
      exact?(IP_ADDRESS, value)
    end

    def number?(value)
      exact?(NUMBER, value)
    end

    def integer?(value)
      exact?(INTEGER, value)
    end

    def date?(value)
      exact?(DATE, value)
    end

    def time?(value)
      exact?(TIME, value)
    end

    def date_time?(value)
      exact?(DATE_TIME, value)
    end
  end
end

class PrivacyFilter
  include RegexConstants

  attr_accessor :preserve_phone_country_code
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username

  def initialize(text)
    @text = text
  end

  def filter_name(name)
    return '[FILTERED]' if name.length < 6
    name[0...3] + '[FILTERED]'
  end

  def filtered_from_email
    result = @text.dup
    result.gsub!(EMAIL) { |s| "#{filter_name $1}@#{$2}" } if partially_preserve_email_username
    result.gsub!(EMAIL, '[FILTERED]@\k<hostname>') if preserve_email_hostname
    result.gsub(EMAIL, '[EMAIL]')
  end

  def filtered
    result = filtered_from_email
    result.gsub!(INTERNATIONAL_PHONE, '\k<prefix> [FILTERED]') if preserve_phone_country_code
    result.gsub(PHONE, '[PHONE]')
  end
end
