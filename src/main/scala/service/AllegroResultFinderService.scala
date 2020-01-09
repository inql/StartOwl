package service


import akka.actor.Actor
import akka.http.scaladsl.Http
import akka.http.scaladsl.model._
import akka.http.scaladsl.model.HttpMethods._
import akka.http.scaladsl.model.HttpProtocols._
import akka.http.scaladsl.model.MediaTypes._
import akka.http.scaladsl.model.HttpCharsets._
import akka.http.scaladsl.model.headers.BasicHttpCredentials
import akka.http.scaladsl.unmarshalling.Unmarshal
import akka.stream.scaladsl.Source
import akka.stream.{ActorMaterializer, Materializer}
import akka.util.ByteString
import exception.AuthorizationException
import javax.inject.Inject
import model.ShopSearchRequest
import model.allegro_api.AuthorizationResponse
import util.AkkaSystemUtils
import util.ImplicitJsonConversions._
import util.TypesDef.MappedAllegroSearchResult

import scala.concurrent.{ExecutionContextExecutor, Future}
import scala.util.{Failure, Success}
class AllegroResultFinderService@Inject extends AkkaSystemUtils{

  implicit val executionContext: ExecutionContextExecutor = system.dispatcher

    def authorize(): Future[AuthorizationResponse] = {


      val clientID = "719b0aca625546c69093cf5e29fd31f3"
      val clientSecret = "VDpirjkVq84r0wLQYRpRZ1BRZcTf1p3yNsLJCYZ3Zh8PsXMgYkOqh6g8hJU4N4D9"

      val authorization = headers.Authorization(BasicHttpCredentials(clientID, clientSecret))
      
      sendRequest("https://allegro.pl/auth/oauth/token?grant_type=client_credentials",POST,List(authorization))
        .onComplete {
          case Success(res: HttpResponse) =>
            Unmarshal[HttpEntity](res.entity.withContentType(ContentTypes.`application/json`)).to[AuthorizationResponse]
          case Failure(_)   => {
            sys.error("Authorization with Allegro API failed. Exiting...")
            Future.failed(new AuthorizationException)
          }
        }
      Future.failed(new AuthorizationException)
    }

  def init(shopSearchRequest: ShopSearchRequest): Unit = {
    authorize()
      .onComplete {
        case Success(authorizationResponse: AuthorizationResponse) =>
          val authToken = authorizationResponse.access_token
        case Failure(_) =>
          foo
      }
  }

  def foo = ???



  def performSearch(authorizationResponse: AuthorizationResponse, shopSearchRequest: ShopSearchRequest): MappedAllegroSearchResult = {
     val apiUrlPath: String = s"https://api.allegro.pl/offers/listing?price.from=${shopSearchRequest.priceFrom}&price.to=${shopSearchRequest.priceTo}&${shopSearchRequest.phrases.mkString("&phrase=")}&sort=-relevance"

  }


  def sendRequest(url: String, httpMethod: HttpMethod, headersList: List[HttpHeader]): Future[HttpResponse] = {
    val request = HttpRequest(
      httpMethod,
      uri = url,
      headers = headersList,
      protocol = `HTTP/1.1`
    )

    Http().singleRequest(request)
  }
}
