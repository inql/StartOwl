package service

import javax.inject.Inject
import model.{ApiSearchResult, SearchRequest}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.AkkaSystemUtils
import java.net.URL

import com.rometools.rome.feed.synd.{SyndEntry, SyndFeed}
import com.rometools.rome.io.SyndFeedInput
import com.rometools.rome.io.XmlReader

import scala.collection.JavaConverters._
import scala.annotation.tailrec
import scala.concurrent.Future

class AtomAndRssService@Inject extends AkkaSystemUtils{

  val browser = JsoupBrowser()

  def search(query: SearchRequest): Future[Map[String, Seq[ApiSearchResult]]] = {
    system.log.info(s"Received request to get data from: ${query}")
    //todo: for now it only gives the title to given result
    val feedUrl = new URL(query.domain)
    val input = new SyndFeedInput
    val feed: SyndFeed = input.build(new XmlReader(feedUrl))
    val entries = asScalaBuffer(feed.getEntries).toVector

    Future.successful(getAllResults(query.keyword,entries))
  }

  def getAllResults(keywords: List[String], allEntries: Vector[SyndEntry]): Map[String,Seq[ApiSearchResult]] = {
    @tailrec
    def getAllResultsFromKeyword(keywords: List[String], allEntries: Vector[SyndEntry], result: Seq[ApiSearchResult]): Seq[ApiSearchResult] = keywords match {
      case Nil => result
      case keyword :: rest => getAllResultsFromKeyword(
        rest, allEntries,
        (for (element <- allEntries.filter(_.toString.contains(keyword)))
          yield ApiSearchResult(element.getUri,element.getTitle,element.getDescription.getValue,element.getEnclosures.get(0).getUrl,element.getLink,element.getPublishedDate.getTime)) ++ result)
    }
    system.log.info(s"This is all entries: ${allEntries.toString()}")
    Map("results" -> getAllResultsFromKeyword(keywords,allEntries,Seq()))
  }

}


