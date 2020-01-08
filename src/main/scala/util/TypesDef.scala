package util

import model.{ApiSearchResult, IconModel, ShopSearchResult}

object TypesDef {
  type MappedApiSearchResult = Map[String,Seq[ApiSearchResult]]
  type MappedShopSearchResult = Map[String, Seq[ShopSearchResult]]
  type LogoSearchResult = Seq[IconModel]
}
