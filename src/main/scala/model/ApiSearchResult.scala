package model


case class ApiSearchResult(uri: String, title: String, description: String, imageUrl: List[String], domain: String, publishDate: String, score: Int = 0)

