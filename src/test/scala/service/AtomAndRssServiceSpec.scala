package service

import model.SearchRequest
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}

class AtomAndRssServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach {

  var emptyRequest, wrongUrlRequest, correctRequest, multipleTagsRequest: SearchRequest = _
  var rssPolsatXml, rssTvnXml, rssEmptyXml, rssWrongXml: String = _

  override def beforeEach(): Unit = {
    rssPolsatXml = getClass.getResource("../rssPolsat.xml").getPath
    print(rssPolsatXml+"\n\n")
  }

  "Atom and Rss service" should {
    "foo foo test" in {
      assert(0 == 0)
    }
  }



}
