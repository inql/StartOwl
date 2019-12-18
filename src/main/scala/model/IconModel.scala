package model

import model.ImageFormat.ImageFormat

case class IconModel(uri: String, size: IconSize, format: ImageFormat) extends BaseModel

case class IconSize(height: Int, width: Int) extends Ordered[IconSize] {
  import scala.math.Ordered.orderingToOrdered
  override def compare(that: IconSize): Int = (this.height, this.width) compare (that.height, that.width)
}
