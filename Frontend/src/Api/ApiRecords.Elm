module Api.ApiRecords exposing (..)

import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, field, list, map2, string)
import Json.Encode as Encode
import SiteItems.Record exposing (..)


api_url : String
api_url =
    "http://localhost:8001/searchrequest/"


encodeCategory : List String -> Encode.Value
encodeCategory tags =
    Encode.object
        [ ( "keyword", Encode.list Encode.string tags )
        , ( "domain", Encode.string "https://www.polsatnews.pl/rss/wszystkie.xml" )
        ]


recordsDecoder : Decoder (List Record)
recordsDecoder =
    field "results" (list decodeRecord)


decodeRecord : Decoder Record
decodeRecord =
    map2 Record
        (field "uri"
            string
        )
        (field
            "title"
            string
        )
