package model

case class SearchRequest(domains: List[Option[String]], keyword: List[String] = List())
