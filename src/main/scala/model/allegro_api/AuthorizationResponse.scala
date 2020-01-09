package model.allegro_api

case class AuthorizationResponse(access_token: String, token_type: String, expires_in: String, scope: String, jti: String)
