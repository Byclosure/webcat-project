# Be sure to restart your server when you modify this file.

Gitlab::Application.config.session_store(
  :cookie_store, # Using the cookie_store would enable session replay attacks.
  key: '_webcat_session',
)
