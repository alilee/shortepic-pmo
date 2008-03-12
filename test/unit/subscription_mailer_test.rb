require File.dirname(__FILE__) + '/../test_helper'
require 'subscription_mailer'

class SubscriptionMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting
  fixtures :codes, :statuses, :items, :person_details
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @item = Issue.find(:first)
    @person = Person.find(:first)
  end

  def test_user_notification
    response = SubscriptionMailer.create_user_notification(@person, @item)
    assert_equal "[PMO] #{@item.class.name} updated - #{@item.title}", response.subject
    #assert_equal @person.full_email, response.to[0]
    assert_match %r{#{@item.class.name.underscore}}, response.body
    assert_match %r{#{@item.id}}, response.body
  end
  
  def test_summary
    response = SubscriptionMailer.create_summary(@person)
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/subscription_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
