package core

import java.net.MalformedURLException

import akka.http.scaladsl.model.{HttpEntity, HttpMethods, HttpRequest, MediaTypes}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.testkit.ScalatestRouteTest
import akka.util.ByteString
import model.{ApiSearchResult, SearchRequest, ShopSearchRequest, ShopSearchResult}
import org.scalamock.scalatest.{AsyncMockFactory, MockFactory}
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import service.{AllegroResultFinderService, AtomAndRssService}

import scala.concurrent.Future

object TestVariables {
  val incorrectSearchRequest: SearchRequest = SearchRequest(List(Option("wrong.url")), "contains")
  val correctSearchRequest: SearchRequest = SearchRequest(List(Option("https://correct.url.com")), "contains", List("Test1","Test2"))
  val emptyShopSearchRequest: ShopSearchRequest = ShopSearchRequest(0,0,List(),"",0)
  val correctShopSearchRequest: ShopSearchRequest = ShopSearchRequest(10,1000,List("Szafa"),"DESCRIPTIONS",1)
}

object MockHelper extends AsyncMockFactory {
  val incorrectMockAtomAndRssService = {
    val fm = mock[AtomAndRssService]
    (fm.findAllResults _).expects(TestVariables.incorrectSearchRequest).returning(Future.successful(Map("results" -> List()))).noMoreThanOnce()
    fm
  }
  val correctMockAtomAndRssService = {
    val fm = mock[AtomAndRssService]
    (fm.findAllResults _).expects(TestVariables.correctSearchRequest).returning(Future.successful(Map("results" -> List()))).noMoreThanOnce()
    fm
  }

  val emptyMockAllegroResultFinderService = {
    val fm = mock[AllegroResultFinderService]
    (fm.init _).expects(TestVariables.emptyShopSearchRequest).returning(Future.successful(Map("results" -> List()))).noMoreThanOnce()
    fm
  }

  val correctMockAllegroResultFinderService = {
    val fm = mock[AllegroResultFinderService]
    (fm.init _).expects(TestVariables.correctShopSearchRequest).returning(Future.successful(Map("results" -> List(ShopSearchResult("Szafa",10.0,"PLN","https://image.com/url",100.00,"https://result.com/url"))))).noMoreThanOnce()
    fm
  }

}

class RoutesSpec extends WordSpec with Matchers with ScalatestRouteTest with BeforeAndAfterEach {



  object IncorrectMockRoutes extends Routes(MockHelper.incorrectMockAtomAndRssService, null)
  object CorrectMockRoutes extends Routes(MockHelper.correctMockAtomAndRssService, null)
  object EmptyMockRoutes extends Routes(null, MockHelper.emptyMockAllegroResultFinderService)
  object CorrectAllegroRoutes extends Routes(null, MockHelper.correctMockAllegroResultFinderService)
  "The Routes Service" should {

    "return \"OK\" value as a response for a GET request to /healthcheck" in {

      val getRequest = HttpRequest(
        HttpMethods.GET,
        uri = "/healthcheck"
      )

      getRequest ~> Route.seal(IncorrectMockRoutes.routes) ~> check {
        status.isSuccess() shouldEqual true
        responseAs[String] shouldEqual "OK"
      }
    }

    "return \"The requested resource could not be found.\" value as a response for a GET request to /unknown" in {

      val getRequest = HttpRequest(
        HttpMethods.GET,
        uri = "/unknown"
      )

      getRequest ~> Route.seal(IncorrectMockRoutes.routes) ~> check {
        status.isFailure() shouldEqual true
        responseAs[String] shouldEqual "The requested resource could not be found."
      }

    }

    "return \"Internal server error\" value as a response for a POST request to /searchrequest" in {

      val jsonRequest = ByteString(
        s"""

           |{

           |    "domains":["wrong.url"],

           |    "searchModeInput":"contains",

           |    "keyword":[]

           |}

        """.stripMargin)

      val postRequest = HttpRequest(
        HttpMethods.POST,
        uri = "/searchrequest",
        entity = HttpEntity(MediaTypes.`application/json`, jsonRequest)
      )

      postRequest ~> Route.seal(IncorrectMockRoutes.routes) ~> check {
        status.isSuccess() shouldEqual true
      }

    }

    "return actual result as a response for a POST request to /searchrequest" in {
      val jsonRequest = ByteString(
        s"""

           |{

           |    "domains":["https://correct.url.com"],

           |    "searchModeInput":"contains",

           |    "keyword":["Test1","Test2"]

           |}

        """.stripMargin)

      val postRequest = HttpRequest(
        HttpMethods.POST,
        uri = "/searchrequest",
        entity = HttpEntity(MediaTypes.`application/json`, jsonRequest)
      )

      postRequest ~> Route.seal(CorrectMockRoutes.routes) ~> check {
        status.isSuccess() shouldEqual true
      }
    }

  }

  "return empty result as a response for a empty POST request to /allegrosearch " in {
    val jsonRequest = ByteString(
      s"""

         |{

         |    "priceFrom":0,
         |    "priceTo":0,
         |    "phrases":[],
         |    "searchMode":"",
         |    "limit":0

         |}

        """.stripMargin)

    val postRequest = HttpRequest(
      HttpMethods.POST,
      uri = "/allegrosearch",
      entity = HttpEntity(MediaTypes.`application/json`, jsonRequest)
    )

    postRequest ~> Route.seal(EmptyMockRoutes.routes) ~> check {
      status.isSuccess() shouldEqual true
    }
  }

  "return non-empty result as a response for a correct POST request to /allegrosearch " in {
    val jsonRequest = ByteString(
      s"""

         |{

         |    "priceFrom":10,
         |    "priceTo":1000,
         |    "searchModeInput":"contains",
         |    "phrases":["Szafa"],
         |    "searchMode":"DESCRIPTIONS",
         |    "limit":1

         |}

        """.stripMargin)

    val postRequest = HttpRequest(
      HttpMethods.POST,
      uri = "/allegrosearch",
      entity = HttpEntity(MediaTypes.`application/json`, jsonRequest)
    )

    postRequest ~> Route.seal(CorrectAllegroRoutes.routes) ~> check {
      status.isSuccess() shouldEqual true
    }
  }


}
