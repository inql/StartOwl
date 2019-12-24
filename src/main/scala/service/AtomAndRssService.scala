package service

import java.io.FileNotFoundException

import javax.inject.Inject
import model.{ApiSearchResult, SearchMode, SearchRequest}
import util.AkkaSystemUtils
import java.net.{MalformedURLException, URL}

import com.rometools.rome.feed.synd.{SyndEnclosure, SyndEntry, SyndFeed}
import com.rometools.rome.io.SyndFeedInput
import com.rometools.rome.io.XmlReader
import util.TypesDef.MappedApiSearchResult

import scala.collection.JavaConverters._
import scala.annotation.tailrec
import scala.concurrent.Future
import scala.io.Source
import scala.util.matching.Regex

class AtomAndRssService@Inject extends AkkaSystemUtils{

  val imgTagPattern: Regex = "<img.*?src=\"(.*?)\"[^>]+>".r
  val imgSrcPattern: Regex = "https?://([^\"]+)".r
  val domainPattern: Regex = "^(?://|[^/]+)*".r
  val htmlTagPattern: Regex = "<[^>]*>".r
  var domainName: String = _
  var iconFinderService: IconFinderService = _
  var keywords: List[String] = _

  def findAllResults(query: SearchRequest): Future[MappedApiSearchResult] = {

    def searchLoop(allDomains: List[Option[String]], result: Seq[ApiSearchResult] = Seq()): Seq[ApiSearchResult] = allDomains match {
      case Nil => result
      case head :: tail => searchLoop(tail,(result ++ search(head,query.keyword, query.searchMode)))
    }

    keywords = query.keyword

    Future.successful(Map("results" -> searchLoop(query.domains)))

  }

  def search(domain: Option[String], keywords: List[String], searchMode: SearchMode): Seq[ApiSearchResult] = {
    system.log.info(s"Received request to get data from: ${domain} that matches ${keywords}")
    try{
      val feedUrl = new URL(
        domain.getOrElse(
          throw new IllegalArgumentException
        ))

      val input = new SyndFeedInput
      val feed: SyndFeed = input.build(new XmlReader(feedUrl))
      val entries = asScalaBuffer(feed.getEntries).toVector


      iconFinderService = new IconFinderService(
        domainName = domainPattern.findFirstIn(feedUrl.getPath).getOrElse("Unknown domain"))

      getAllResults(keywords,entries, searchMode)
    }
    catch {
      case x: MalformedURLException =>
        system.log.error("Given URL is not correct!")
        Seq()
      case x: IllegalArgumentException =>
        system.log.error("Given URL cannot be null!")
        Seq()
    }
  }

  def getAllResults(keywords: List[String], allEntries: Vector[SyndEntry], searchMode: SearchMode): Seq[ApiSearchResult] = {

    def buildSearchResult(entry: SyndEntry): ApiSearchResult = {

      def getDomainName: String = domainPattern.findFirstIn(entry.getUri).getOrElse("Unknown domain")

      def getPublishedDate: String = entry.getPublishedDate.toString

      def getDescription: String = imgTagPattern.replaceAllIn(entry.getDescription.getValue,"").replaceAll(htmlTagPattern.regex,"").trim

      def getResultScore: Int = searchMode.score(keywords, getDescription)

      def checkImage(uri:String) : String = {
        try{
          val wholeImage = Source.fromURL(uri)
          uri
        }
        catch {
          case x @ (_ :FileNotFoundException | _: MalformedURLException) => new IconFinderService(getDomainName).getBestLogoCandidate().uri
        }
      }

      def buildResultWithoutEnclosures(imgUrls: List[String]): ApiSearchResult = {
        val imagePath = imgTagPattern.findAllIn(entry.getDescription.getValue).toList.map(t => checkImage(imgSrcPattern.findFirstIn(t).getOrElse("Unknown image.")))
        ApiSearchResult(entry.getUri,entry.getTitle,getDescription,imagePath ::: imgUrls, getDomainName, getPublishedDate, getResultScore)
      }

      @tailrec
      def buildResultFromRssEntry(enclosures: List[SyndEnclosure], imgUrls: List[String] = List()): ApiSearchResult = enclosures match {
        case Nil => buildResultWithoutEnclosures(imgUrls)
        case enclosure :: rest => buildResultFromRssEntry(rest, checkImage(enclosure.getUrl) :: imgUrls)
      }

      buildResultFromRssEntry(asScalaBuffer(entry.getEnclosures).toList)
    }

    @tailrec
    def getAllResultsFromKeyword(keywords: List[String], allEntries: Vector[SyndEntry], result: Seq[ApiSearchResult] = Seq()): Seq[ApiSearchResult] = keywords match {
      case Nil => result
      case keyword :: rest => getAllResultsFromKeyword(
        rest, allEntries,
        (for (element <- allEntries.filter(searchMode.filter(_,keyword)))
          yield buildSearchResult(element)) ++ result)
    }
    getAllResultsFromKeyword(keywords,allEntries)
  }

}


