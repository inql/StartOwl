package model

import com.rometools.rome.feed.synd.SyndEntry

case class SearchMode(name: String, filter: (SyndEntry, String) => Boolean, score: (List[String], String) => Int)

object SearchMode {

  def buildSearchMode(name: String): SearchMode = name match {
    case "contains" => contains
    case _ => contains
  }


  def containsFilter: (SyndEntry, String) => Boolean = (e: SyndEntry, s: String) => {e.getDescription.getValue.contains(s)}
  def containsFilterScore: (List[String], String) => Int = (str: List[String], sub: String) => str.count(sub.contains(_))

  val contains = SearchMode("contains", (e: SyndEntry, s: String) => {e.getDescription.getValue.contains(s)}, containsFilterScore)
}
