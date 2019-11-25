module Api.ApiRecords exposing (..)

import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, list, string)
import SiteItems.Record exposing (..)


type Model
    = Int
