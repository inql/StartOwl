package model


case class ApiSearchResult(uri: String, title: String, description: String, imageUrl: String, domain: String, publishDate: String, score: Int = 0)

