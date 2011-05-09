# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_auth_session',
  :secret      => 'a0b20d5e7ec230f9358cae2b5b4a2a5435b2b5b7cd02eadbae0574d5bdd1975c8b109795b45924a1b06dd615292d936138dcb300c1adecf9114e971fda185f46'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
