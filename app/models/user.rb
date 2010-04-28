class User < ActiveRecord::Base
  acts_as_authentic do |auth|
    auth.logged_in_timeout = 60.minutes
  end
end
