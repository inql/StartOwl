package model.allegro_api

case class AuthorizationResponse(access_token: String, token_type: String, expires_in: Int, scope: String, jti: String)
