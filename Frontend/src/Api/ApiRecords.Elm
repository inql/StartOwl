module Api.ApiRecords exposing (..)

import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, field, list, map2, string)
import SiteItems.Record exposing (..)


api_url : String
api_url =
    "http://localhost:5016/data.json"


recordsDecoder : Decoder (List Record)
recordsDecoder =
    field "records" (list decodeRecord)


decodeRecord : Decoder Record
decodeRecord =
    map2 Record
        (field "url"
            string
        )
        (field
            "title"
            string
        )
