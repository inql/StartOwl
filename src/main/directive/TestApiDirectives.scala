package main.directive

import scala.util.{Failure, Success}
import akka.http.scaladsl.server.{Directive1, Directives}
import main.model.ApiError

import scala.concurrent.Future

trait TestApiDirectives extends Directives{
  import de.heikoseeberger.akkahttpcirce.FailFastCirceSupport._
  import io.circe.generic.auto._

  def handle[T]
  (f: Future[T])
  (e: Throwable => ApiError): Directive1[T] = onComplete(f) flatMap {
    case Success(t) =>
      provide(t)
    case Failure(error) =>
      val apiError = e(error)
      complete(apiError.statusCode, apiError.message)
  }

  def handleWithGeneric[T](f: Future[T]): Directive1[T] =
    handle[T](f)(_ => ApiError.generic)
}
