package service

import model.ShopSearchRequest
import org.scalamock.scalatest.AsyncMockFactory
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import org.scalatest.concurrent.ScalaFutures
import util.TypesDef.MappedAllegroSearchResult

import scala.concurrent.Future

class AllegroResultFinderServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach with ScalaFutures {

  var emptyRequest, wrongPricesRequest, correctRequest, multiplePhrasesRequest, wrongSearchModeRequest, invalidLimitRequest, exactLimitRequest: ShopSearchRequest = _

  var allegroResultFinderService: AllegroResultFinderService = _

  override def beforeEach(): Unit = {
    emptyRequest = ShopSearchRequest(0,0,List(),"",0)
    wrongPricesRequest = ShopSearchRequest(1000,-100,List("Playstation"),"",10)
    correctRequest = ShopSearchRequest(10,1000,List("Szafa"), "DESCRIPTIONS",10)
    multiplePhrasesRequest = ShopSearchRequest(0,2000,List("Konsola", "Playstation", "Książka"),"DESCRIPTIONS",10)
    wrongSearchModeRequest = ShopSearchRequest(0,100,List("Widelec"), "wr0ngSearcHm0d3",10)
    invalidLimitRequest = ShopSearchRequest(0,100,List("Sukienka"),"",-100)
    exactLimitRequest = ShopSearchRequest(0,100,List("Gra komputerowa"), "", 5)

    allegroResultFinderService = new AllegroResultFinderService
  }

  "Allegro result finder service" should {

    "return empty result when empty request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(emptyRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") shouldBe empty
      }}
    }

    "return non empty result when wrong prices are given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(wrongPricesRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") should not be empty
      }}
    }

    "return non empty result when correct request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(correctRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") should not be empty
      }}
    }

    "return non empty result when multiple phrases request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(multiplePhrasesRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") should not be empty
      }}
    }

    "return non empty result when wrong search mode request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(wrongSearchModeRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") should not be empty
      }}
    }

    "return an empty result when invalid limit request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(invalidLimitRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") shouldBe empty
      }}
    }

    "return non empty result with specific size when exact limit request is given" in {
      val f: Future[MappedAllegroSearchResult] = allegroResultFinderService.init(exactLimitRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedAllegroSearchResult]
        s("results") should not be empty
        s("results") should have size 5
      }}
    }


  }




}
