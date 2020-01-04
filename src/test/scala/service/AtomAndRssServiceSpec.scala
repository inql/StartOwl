package service

import model.{ApiSearchResult, SearchMode, SearchRequest}
import org.scalatest.concurrent.ScalaFutures
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import util.TypesDef.MappedApiSearchResult

import scala.concurrent.Future

class AtomAndRssServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach with ScalaFutures {

  var emptyRequest, wrongUrlRequest, noTagsRequest, correctRequest, multipleTagsRequest, nullUrlRequest, nullTagsRequest: SearchRequest = _
  var rssPolsatXml, rssTvnXml, rssEmptyXml: Option[String] = _
  var atomAndRssService: AtomAndRssService = _

  override def beforeEach(): Unit = {
    rssPolsatXml = Option("https://www.polsatnews.pl/rss/wszystkie.xml")
    rssTvnXml = Option("https://tvn24.pl/najwazniejsze.xml")

    emptyRequest = SearchRequest(List(Option("xd")), "contains",List())
    wrongUrlRequest = SearchRequest(List(Option("wrong.url")), "contains", List())
    correctRequest = SearchRequest(List(rssPolsatXml), "contains", List("a"))
    multipleTagsRequest = SearchRequest(List(rssTvnXml), "contains", List("b", "a"))
    noTagsRequest = SearchRequest(List(rssTvnXml), "contains", List())

    nullUrlRequest = SearchRequest(List(Option("xd")), "contains")
    nullTagsRequest = SearchRequest(List(rssTvnXml), "contains", null)

    atomAndRssService = new AtomAndRssService
  }

  "Atom and Rss service" should {

    "return empty result when empty request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(emptyRequest)
      whenReady(f) { s => {
        s shouldBe a [MappedApiSearchResult]
        s("results") shouldBe empty
      }}
    }

    "return empty result when invalid request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(wrongUrlRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "return empty result when null value is provided as a domain" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(nullUrlRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a correct mapped result when valid request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(correctRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a correct mapped result when valid multiple tag request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(multipleTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a correct mapped result when no tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(noTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a non-empty result when one tag is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(correctRequest)
      whenReady(f) { s => s("results") should not be empty}
    }

    "provide a non-empty result when more tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(multipleTagsRequest)
      whenReady(f) { s => s("results") should not be empty}
    }

    "provide an empty result when no tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(noTagsRequest)
      whenReady(f) { s => s("results") shouldBe empty}
    }

    "provide an exact result when one tag is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(correctRequest)
      whenReady(f) { s =>
          s("results") should not be empty
          s("results").head.description.toCharArray should contain ('a')
          s("results").head.score should be > 0
      }
    }

    "provide an exact result when multiple tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.findAllResults(multipleTagsRequest)
      whenReady(f) { s =>
        s("results") should not be empty
        s("results").head.description.toCharArray should contain atLeastOneOf ('a', 'b')
        s("results").head.score should be > 0
      }
    }


  }



}
