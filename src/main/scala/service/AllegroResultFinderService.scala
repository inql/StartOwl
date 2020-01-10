package service


import java.util.Base64

import akka.actor.Actor
import akka.http.scaladsl.Http
import akka.http.scaladsl.model._
import akka.http.scaladsl.model.HttpMethods._
import akka.http.scaladsl.model.HttpProtocols._
import akka.http.scaladsl.model.MediaTypes._
import akka.http.scaladsl.model.HttpCharsets._
import akka.http.scaladsl.model.headers.{BasicHttpCredentials, OAuth2BearerToken}
import akka.http.scaladsl.unmarshalling.Unmarshal
import akka.stream.scaladsl.Source
import akka.stream.{ActorMaterializer, Materializer}
import akka.util.ByteString
import exception.AuthorizationException
import io.circe.{Decoder, Encoder, Json, parser}
import io.circe.generic.auto._
import io.circe.parser._
import io.circe.optics.JsonPath._
import javax.inject.Inject
import model.{ShopSearchRequest, ShopSearchResult}
import model.allegro_api.AuthorizationResponse
import org.apache.http.HttpHeaders
import org.apache.http.client.methods.{HttpGet, HttpPost}
import org.apache.http.impl.client.HttpClients
import org.apache.http.message.BasicHeader
import org.apache.http.util.EntityUtils
import io.circe.optics.JsonPath._
import org.jboss.netty.handler.codec.base64.Base64Encoder
import util.AkkaSystemUtils
import util.ImplicitJsonConversions._
import util.TypesDef.MappedAllegroSearchResult

import scala.concurrent.{Await, ExecutionContextExecutor, Future}
import scala.concurrent.duration._
import scala.util.{Failure, Success}
class AllegroResultFinderService@Inject extends AkkaSystemUtils{

  implicit val executionContext: ExecutionContextExecutor = system.dispatcher

  def authorize(): Option[AuthorizationResponse] = {

      val clientID = "719b0aca625546c69093cf5e29fd31f3"
      val clientSecret = "VDpirjkVq84r0wLQYRpRZ1BRZcTf1p3yNsLJCYZ3Zh8PsXMgYkOqh6g8hJU4N4D9"
      val encoding = Base64.getEncoder.encodeToString((s"${clientID}:${clientSecret}").getBytes)
      val url = "https://allegro.pl/auth/oauth/token?grant_type=client_credentials"

      sendRequest[AuthorizationResponse](url,"POST",List(new BasicHeader(HttpHeaders.AUTHORIZATION, "Basic " + encoding)))
    }

  def init(shopSearchRequest: ShopSearchRequest): Future[MappedAllegroSearchResult] = authorize() match {
    case Some(authorizationResponse) =>performSearch(authorizationResponse,shopSearchRequest)
    case None => Future(Map("result" -> Seq()))
  }

  def performSearch(authorizationResponse: AuthorizationResponse, shopSearchRequest: ShopSearchRequest): Future[MappedAllegroSearchResult] = {
    val searchMode = shopSearchRequest.searchMode match {
      case x if List("REGULAR","DESCRIPTIONS","CLOSED").contains(x.toUpperCase) => x
      case _ => "REGULAR"
    }
    val apiUrlPath: String = s"https://api.allegro.pl/offers/listing?price.from=${shopSearchRequest.priceFrom}&price.to=${shopSearchRequest.priceTo}&phrase=${shopSearchRequest.phrases.map(x => x.replaceAll("\\s","+")).mkString("&phrase=")}&searchMode=${searchMode}&limit=${shopSearchRequest.limit}&sort=-relevance"
    system.log.info("Api url path = " + apiUrlPath)
    val auth = List(new BasicHeader(HttpHeaders.AUTHORIZATION, "Bearer " + authorizationResponse.access_token), new BasicHeader(HttpHeaders.ACCEPT, "application/vnd.allegro.public.v1+json"))
    sendRequest[List[ShopSearchResult]](apiUrlPath,"GET",auth, resultParser) match {
      case Some(x) => Future(Map("results" -> x))
      case None => Future(Map("results" -> Seq()))
    }
  }

  def sendRequest[A](url: String, httpMethod: String, headersList: List[BasicHeader], parserFun: String => String = input => input)(implicit decoder: Decoder[A]): Option[A] = {
    val httpClient = HttpClients.createDefault()
    var request: org.apache.http.client.methods.HttpRequestBase = null
    httpMethod match {
      case "GET" => request = new HttpGet(url)
      case "POST" => request = new HttpPost(url)
    }
    headersList.foreach{
      request.addHeader(_)
    }
    val response = httpClient.execute(request)
    val rawResponse = parserFun(EntityUtils.toString(response.getEntity))
    parser.decode[A](rawResponse).toOption
  }


  def resultParser(input: String): String = {
    val json: Json = parse(input).getOrElse(Json.Null)
    val items: Vector[Json] = root.items.promoted.json.getOption(json) match {
      case Some(x) => x.asArray.getOrElse(Vector())
      case None => Vector()
    }
    Json.fromValues(for {
      item <- items
    } yield Json.fromFields(List(
      ("name", Json.fromString(root.name.string.getOption(item).get)),
      ("lowestPriceDelivery", Json.fromString(root.delivery.lowestPrice.amount.string.getOption(item).get)),
      ("currency", Json.fromString(root.delivery.lowestPrice.currency.string.getOption(item).get)),
      ("imageUri", Json.fromString(root.images.arr.getOption(item).get(0).hcursor.get[String]("url").toOption.get)),
      ("price", Json.fromString(root.sellingMode.price.amount.string.getOption(item).get)),
      ("uri", Json.fromString(s"https://allegro.pl/oferta/${root.id.string.getOption(item).get}"))
    ))).toString()
  }
}
