module Api.ApiConnection exposing (..)

import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, field, list, map4, string)
import Json.Encode as Encode
import SiteItems.Record exposing (..)


api_url : String
api_url =
    "https://startowl.azurewebsites.net/searchrequest/"


query_url : String
query_url =
    "https://startowl.azurewebsites.net/allegrosearch/"


preparePostJsonForCategory : List String -> List String -> Encode.Value
preparePostJsonForCategory tags urls =
    Encode.object
        [ ( "keyword", Encode.list Encode.string tags )
        , ( "domains", Encode.list Encode.string urls )
        , ( "searchModeInput", Encode.string "contains" )
        ]


preparePostJsonForShoppingQuery : Int -> Int -> List String -> Encode.Value
preparePostJsonForShoppingQuery priceFrom priceTo phrases =
    Encode.object
        [ ( "priceFrom", Encode.int priceFrom )
        , ( "priceTo", Encode.int priceTo )
        , ( "phrases", Encode.list Encode.string phrases )
        , ( "limit", Encode.int 10 )
        , ( "searchMode", Encode.string "DESCRIPTIONS" )
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
        (field "imageUrl" string)
