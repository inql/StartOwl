package model

import model.ImageFormat.ImageFormat

case class IconModel(uri: String, width: Int, height: Int, format: ImageFormat, size: Long)
