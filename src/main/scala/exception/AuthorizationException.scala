package exception

final case class AuthorizationException(private val message: String = "Authorization failed!",
                                        private val cause: Throwable = None.orNull)
  extends Exception(message, cause)