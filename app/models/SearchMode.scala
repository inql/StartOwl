package models

object SearchMode extends Enumeration {
  type SearchMode = Value
  val CONTAINS_EACH, CONTAINS_ALL, CONTAINS_NONE = Value
}
