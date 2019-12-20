package model

case class SearchRequest(domains: List[Option[String]],searchModeInput: String, keyword: List[String] = List()){
  val searchMode: SearchMode = SearchMode.buildSearchMode(searchModeInput)
}
