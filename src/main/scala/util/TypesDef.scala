package util

import model.{ApiSearchResult, IconModel}

object TypesDef {
  type MappedApiSearchResult = Map[String,Seq[ApiSearchResult]]
  type LogoSearchResult = Seq[IconModel]
}
