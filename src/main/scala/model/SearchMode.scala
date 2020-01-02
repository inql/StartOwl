package model

import com.rometools.rome.feed.synd.SyndEntry

case class SearchMode(name: String, filter: (SyndEntry, String) => Boolean, score: (List[String], SyndEntry) => Int)

object SearchMode {

  def buildSearchMode(name: String): SearchMode = name match {
    case "contains" => contains
    case _ => contains
  }


  def containsFilter: (SyndEntry, String) => Boolean = (e: SyndEntry, s: String) => {e.getDescription.getValue.contains(s)}
  def containsFilterScore: (List[String], SyndEntry) => Int = (str: List[String], sub: SyndEntry) => str.count(sub.getDescription.getValue.contains(_))

  val contains = SearchMode("contains", containsFilter, containsFilterScore)
}
