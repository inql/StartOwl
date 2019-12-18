package model

object ImageFormat extends Enumeration {

  type ImageFormat = Value

  val PNG = Value(".png")
  val IMG = Value(".img")
  val ICO = Value(".ico")

  def withNameOpt(s: String): Option[Value] = values.find(_.toString == s)

}
