package service

import java.net.MalformedURLException

import model.{ApiSearchResult, SearchRequest}
import org.scalatest.concurrent.ScalaFutures
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}

import scala.concurrent.Future

class AtomAndRssServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach with ScalaFutures {

  var emptyRequest, wrongUrlRequest, correctRequest, multipleTagsRequest: SearchRequest = _
  var rssPolsatXml, rssTvnXml, rssEmptyXml, rssWrongXml: String = _
  var atomAndRssService: AtomAndRssService = _

  override def beforeEach(): Unit = {
    rssPolsatXml = getClass.getResource("../rssPolsat.xml").getPath
    rssTvnXml = getClass.getResource("../rssTvn.xml").getPath

    emptyRequest = SearchRequest("",List())
    wrongUrlRequest = SearchRequest("wrong.url",List())
    correctRequest = SearchRequest(rssPolsatXml, List("Euro"))
    multipleTagsRequest = SearchRequest(rssTvnXml, List("Euro", "Sport"))

    atomAndRssService = new AtomAndRssService
  }

  "Atom and Rss service" should {

    "raise an exception when empty request is given" in {
      val f: Future[Map[String,Seq[ApiSearchResult]]] = atomAndRssService.search(emptyRequest)
      whenReady(f.failed) { s => s shouldBe a [MalformedURLException] }
    }
  }



}
