package service

import javax.inject.Inject
import model.{ApiSearchResult, SearchRequest}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.AkkaSystemUtils
import java.net.URL

import com.rometools.rome.feed.synd.{SyndEnclosure, SyndEntry, SyndFeed}
import com.rometools.rome.io.SyndFeedInput
import com.rometools.rome.io.XmlReader

import scala.collection.JavaConverters._
import scala.annotation.tailrec
import scala.concurrent.Future
import scala.util.matching.Regex

class AtomAndRssService@Inject extends AkkaSystemUtils{
  
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
          yield buildSearchResult(element)) ++ result)
    }
    system.log.info(s"This is all entries: ${allEntries.toString()}")
    Map("results" -> getAllResultsFromKeyword(keywords,allEntries,Seq()))
  }

  def buildSearchResult(entry: SyndEntry): ApiSearchResult = {

    val imgTagPattern = "<img.*?src=\"(.*?)\"[^>]+>".r
    val imgSrcPattern = "https?://([^\"]+)".r
    val domainPattern = "^(?://|[^/]+)*".r

    def getDomainName: String = domainPattern.findFirstIn(entry.getUri).getOrElse("Unknown domain")

    def getPublishedDate: String = entry.getPublishedDate.toString

    def getDescription: String = imgTagPattern.replaceAllIn(entry.getDescription.getValue,"").trim

    def buildResultWithoutEnclosures(imgUrls: List[String]): ApiSearchResult = {
      val imagePath = imgTagPattern.findAllIn(entry.getDescription.getValue).toList.map(t => imgSrcPattern.findFirstIn(t).getOrElse("Unknown image."))
      ApiSearchResult(entry.getUri,entry.getTitle,getDescription,imagePath ::: imgUrls, getDomainName, getPublishedDate)
    }

    @tailrec
    def buildResultFromRssEntry(enclosures: List[SyndEnclosure], imgUrls: List[String]): ApiSearchResult = enclosures match {
      case Nil => buildResultWithoutEnclosures(imgUrls)
      case enclosure :: rest => buildResultFromRssEntry(rest, enclosure.getUrl :: imgUrls)
    }

    buildResultFromRssEntry(asScalaBuffer(entry.getEnclosures).toList, List())
  }

}


