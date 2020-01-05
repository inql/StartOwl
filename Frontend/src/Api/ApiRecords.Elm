module Api.ApiRecords exposing (..)

import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, field, list, map4, string)
import Json.Encode as Encode
import SiteItems.Record exposing (..)


api_url : String
api_url =
    "http://localhost:8002/searchrequest/"


preparePostJsonForCategory : List String -> Encode.Value
preparePostJsonForCategory tags =
    Encode.object
        [ ( "keyword", Encode.list Encode.string tags )
        , ( "domains", Encode.list Encode.string [ "https://www.tvn24.pl", "https://www.polsatnews.pl" ] )
        , ( "searchModeInput", Encode.string "contains" )
        ]


recordsDecoder : Decoder (List Record)
recordsDecoder =
    field "results" (list decodeRecord)


decodeRecord : Decoder Record
decodeRecord =
    map4 Record
        (field "uri" string)
        (field "title" string)
        (field "description" string)
        (field "imageUrl" (list string))
