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

import scala.None
import scala.collection.JavaConverters._
import scala.annotation.tailrec
import scala.concurrent.Future
import scala.io.Source
import scala.util.matching.Regex

class AtomAndRssService@Inject extends AkkaSystemUtils{

  val rssRegex: Regex = "\\.(xml)$".r

  def findAllResults(query: SearchRequest): Future[MappedApiSearchResult] = {

    @tailrec
    def searchLoop(allDomains: List[Option[String]], result: Seq[ApiSearchResult] = Seq()): Seq[ApiSearchResult] = allDomains match {
      case Nil => result
      case head :: tail => searchLoop(tail,result ++ new ResultFinderService(head,query.keyword, query.searchMode).findAllResultsForDomain())
    }

    @tailrec
    def validateInputs(allDomains: List[Option[String]], result: List[Option[String]] = List()): List[Option[String]] = allDomains match {
      case Nil => result
      case head :: tail => rssRegex.findFirstMatchIn(head.get) match {
        case None => validateInputs(tail, new RssFinderService(head.get).getAllValidRssFeeds().map(Option(_)) ++ result)
        case Some(_) => validateInputs(tail, head :: result)
      }
    }


    Future.successful(Map("results" -> searchLoop(
      validateInputs(query.domains))))

  }

}


