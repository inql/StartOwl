package service

import java.net.MalformedURLException

import model.{ApiSearchResult, SearchRequest}
import org.scalatest.concurrent.ScalaFutures
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import util.TypesDef.MappedResult

import scala.concurrent.Future

class AtomAndRssServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach with ScalaFutures {

  var emptyRequest, wrongUrlRequest, noTagsRequest, correctRequest, multipleTagsRequest, nullUrlRequest: SearchRequest = _
  var rssPolsatXml, rssTvnXml, rssEmptyXml, rssWrongXml: Option[String] = _
  var atomAndRssService: AtomAndRssService = _

  override def beforeEach(): Unit = {
    rssPolsatXml = Option("file://" concat getClass.getResource("../rssPolsat.xml").getPath)
    rssTvnXml = Option("file://" concat getClass.getResource("../rssTvn.xml").getPath)

    emptyRequest = SearchRequest(Option(""),List())
    wrongUrlRequest = SearchRequest(Option("wrong.url"),List())
    correctRequest = SearchRequest(rssPolsatXml, List("Euro"))
    multipleTagsRequest = SearchRequest(rssTvnXml, List("Euro", "Sport"))
    noTagsRequest = SearchRequest(rssTvnXml,List())

    nullUrlRequest = SearchRequest(None)

    atomAndRssService = new AtomAndRssService
  }

  "Atom and Rss service" should {

    "raise an exception when empty request is given" in {
      val f: Future[MappedResult] = atomAndRssService.search(emptyRequest)
      whenReady(f.failed) { s => s shouldBe a [MalformedURLException] }
    }

    "raise an exception when invalid request is given" in {
      val f: Future[MappedResult] = atomAndRssService.search(wrongUrlRequest)
      whenReady(f.failed) { s => s shouldBe a [MalformedURLException]}
    }

    "raise an exception when null value is provided as a domain" in {
      val f: Future[MappedResult] = atomAndRssService.search(nullUrlRequest)
      whenReady(f.failed) { s => s shouldBe a [IllegalArgumentException]}
    }

    "provide a correct mapped result when valid request is given" in {
      val f: Future[MappedResult] = atomAndRssService.search(correctRequest)
      whenReady(f) { s => s shouldBe a [MappedResult]}
    }

    "provide a correct mapped result when valid multiple tag request is given" in {
      val f: Future[MappedResult] = atomAndRssService.search(multipleTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedResult]}
    }

    "provide a correct mapped result when no tags are given" in {
      val f: Future[MappedResult] = atomAndRssService.search(noTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedResult]}
    }
  }



}
