package util

import model.{ApiSearchResult, IconModel, ShopSearchResult}

object TypesDef {
  type MappedApiSearchResult = Map[String,Seq[ApiSearchResult]]
  type MappedAllegroSearchResult = Map[String, Seq[ShopSearchResult]]
  type LogoSearchResult = Seq[IconModel]
}
