package model

case class SearchRequest(domain: Option[String], keyword: List[String] = List())
