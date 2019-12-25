package core

import java.net.MalformedURLException

import akka.http.scaladsl.model.{HttpEntity, HttpMethods, HttpRequest, MediaTypes}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.testkit.ScalatestRouteTest
import akka.util.ByteString
import model.{ApiSearchResult, SearchRequest}
import org.scalamock.scalatest.{AsyncMockFactory, MockFactory}
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import service.AtomAndRssService

import scala.concurrent.Future

object TestVariables {
  val incorrectSearchRequest: SearchRequest = SearchRequest(List(Option("wrong.url")), "contains")
  val correctSearchRequest: SearchRequest = SearchRequest(List(Option("https://correct.url.com")), "contains", List("Test1","Test2"))
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
}

class RoutesSpec extends WordSpec with Matchers with ScalatestRouteTest with BeforeAndAfterEach {



  object IncorrectMockRoutes extends Routes(MockHelper.incorrectMockAtomAndRssService)
  object CorrectMockRoutes extends Routes(MockHelper.correctMockAtomAndRssService)

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


}
