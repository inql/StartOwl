package service

import java.io.{BufferedReader, FileNotFoundException, InputStreamReader}
import java.net.{MalformedURLException, URL}
import java.util.stream.Collectors

import akka.http.scaladsl.model.HttpRequest
import com.rometools.rome.feed.synd.{SyndEnclosure, SyndEntry, SyndFeed}
import com.rometools.rome.io.{ParsingFeedException, SyndFeedInput, XmlReader}
import model.{ApiSearchResult, SearchMode}
import org.apache.http.client.methods.HttpGet
import org.apache.http.impl.client.HttpClients
import util.AkkaSystemUtils

import scala.annotation.tailrec
import scala.collection.JavaConverters.asScalaBuffer
import scala.io.{BufferedSource, Source}
import scala.util.matching.Regex

class ResultFinderService(val domain: Option[String],val keywords: List[String],val searchMode: SearchMode) extends AkkaSystemUtils {

  val imgTagPattern: Regex = "<img.*?src=\"(.*?)\"[^>]+>".r
  val imgSrcPattern: Regex = "https?://([^\"]+)".r
  val domainPattern: Regex = "^(?://|[^/]+)*".r
  val htmlTagPattern: Regex = "<[^>]*>".r
  val filePattern: Regex = "file:\\/\\/\\/.*".r

  var optionalImgUrl: String = _

  def findAllResultsForDomain(): Seq[ApiSearchResult] = {
    system.log.info(s"Received request to get data from: ${domain} that matches ${keywords}")
    try{
      val httpClient = HttpClients.createDefault()
      val httpGet = new HttpGet(domain.get)
      httpGet.addHeader("User-Agent", "Mozilla/5.0")
      val httpResponse = httpClient.execute(httpGet)
      val reader: BufferedReader = new BufferedReader(new InputStreamReader(httpResponse.getEntity.getContent))
      
      val input = new SyndFeedInput
      val feed: SyndFeed = input.build(reader)
      val entries = asScalaBuffer(feed.getEntries).toVector

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

      def getResultScore: Int = searchMode.score(keywords, entry)

      def pickBestImageFromEnclosures(enclosures: List[SyndEnclosure]): String = enclosures.maxBy(_.getLength).getUrl

      def checkImage(uri:String) : String = {
        try{
          val wholeImage = Source.fromURL(uri)
          uri
        }
        catch {
          case x @ (_ :FileNotFoundException | _: MalformedURLException) => {
            if (optionalImgUrl == null) optionalImgUrl = new IconFinderService(domainPattern.findFirstIn(getDomainName).get).getBestLogoCandidate().uri
            optionalImgUrl
          }

        }
      }

      def buildResultWithoutEnclosures(enclosureUrl: String = ""): ApiSearchResult = imgTagPattern.findAllIn(entry.getDescription.getValue).toList.map(t => checkImage(imgSrcPattern.findFirstIn(t).getOrElse("Unknown image"))) match {
          case Nil => ApiSearchResult(entry.getUri,entry.getTitle,getDescription,enclosureUrl, getDomainName, getPublishedDate, getResultScore)
          case head :: rest => ApiSearchResult(entry.getUri,entry.getTitle,getDescription,head, getDomainName, getPublishedDate, getResultScore)
      }

      def buildResultFromRssEntry(enclosures: List[SyndEnclosure]): ApiSearchResult = enclosures match {
        case Nil => buildResultWithoutEnclosures()
        case enclosures: List[SyndEnclosure] => buildResultWithoutEnclosures(pickBestImageFromEnclosures(enclosures))
      }

      buildResultFromRssEntry(asScalaBuffer(entry.getEnclosures).toList.sortBy(_.getLength).reverse)
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
