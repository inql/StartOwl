package model

case class ShopSearchRequest(priceFrom: Double, priceTo: Double, phrases: List[String])
