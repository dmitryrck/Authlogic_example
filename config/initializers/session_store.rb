# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Authlogic_example_session',
  :secret      => 'af911b853eb7eff9a873cebfc3ebf284db71c3a19bc302c702c0dec2ce9ff7fb7584c2f335801027e0a5b833befb0ee8ff7c3a93af94fee040b1f9ca096afd6f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
