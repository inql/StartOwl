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

  def findAllResults(query: SearchRequest): Future[MappedApiSearchResult] = {

    def searchLoop(allDomains: List[Option[String]], result: Seq[ApiSearchResult] = Seq()): Seq[ApiSearchResult] = allDomains match {
      case Nil => result
      case head :: tail => searchLoop(tail,result ++ new ResultFinderService(head,query.keyword, query.searchMode).findAllResultsForDomain())
    }
    Future.successful(Map("results" -> searchLoop(query.domains)))

  }

}


