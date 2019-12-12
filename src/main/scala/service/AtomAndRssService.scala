package service

import javax.inject.Inject
import model.{ApiSearchResult, SearchRequest}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.AkkaSystemUtils
import java.net.{MalformedURLException, URL}

import com.rometools.rome.feed.synd.{SyndEnclosure, SyndEntry, SyndFeed}
import com.rometools.rome.io.SyndFeedInput
import com.rometools.rome.io.XmlReader
import util.TypesDef.MappedApiSearchResult

import scala.collection.JavaConverters._
import scala.annotation.tailrec
import scala.concurrent.Future

class AtomAndRssService@Inject extends AkkaSystemUtils{

  def search(query: SearchRequest): Future[MappedApiSearchResult] = {
    system.log.info(s"Received request to get data from: ${query}")
    try{
      val feedUrl = new URL(
        query.domain.getOrElse(
          throw new IllegalArgumentException
        ))
      val input = new SyndFeedInput
      val feed: SyndFeed = input.build(new XmlReader(feedUrl))
      val entries = asScalaBuffer(feed.getEntries).toVector
      Future.successful(getAllResults(query.keyword,entries))
    }
    catch {
      case x: MalformedURLException =>
        system.log.error("Given URL is not correct!")
        Future.failed(x)
      case x: IllegalArgumentException =>
        system.log.error("Given URL cannot be null!")
        Future failed(x)
    }
  }

  def getAllResults(keywords: List[String], allEntries: Vector[SyndEntry]): MappedApiSearchResult = {
    @tailrec
    def getAllResultsFromKeyword(keywords: List[String], allEntries: Vector[SyndEntry], result: Seq[ApiSearchResult]): Seq[ApiSearchResult] = keywords match {
      case Nil => result
      case keyword :: rest => getAllResultsFromKeyword(
        rest, allEntries,
        (for (element <- allEntries.filter(_.toString.contains(keyword)))
          yield buildSearchResult(element)) ++ result)
    }
    Map("results" -> getAllResultsFromKeyword(keywords,allEntries,Seq()))
  }

  def buildSearchResult(entry: SyndEntry): ApiSearchResult = {

    val imgTagPattern = "<img.*?src=\"(.*?)\"[^>]+>".r
    val imgSrcPattern = "https?://([^\"]+)".r
    val domainPattern = "^(?://|[^/]+)*".r
    val htmlTagPattern = "<[^>]*>".r

    def getDomainName: String = domainPattern.findFirstIn(entry.getUri).getOrElse("Unknown domain")

    def getPublishedDate: String = entry.getPublishedDate.toString

    def getDescription: String = imgTagPattern.replaceAllIn(entry.getDescription.getValue,"").replaceAll(htmlTagPattern.regex,"").trim

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


