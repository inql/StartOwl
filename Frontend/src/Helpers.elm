module Helpers exposing (..)

import Dict exposing (Dict)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Http exposing (..)
import Regex exposing (Regex)
import Time
import TimeZone exposing (..)


defaultTimeZone : Time.Zone
defaultTimeZone =
    europe__warsaw ()


possibleTimeZones : Dict String Time.Zone
possibleTimeZones =
    [ ( "", europe__warsaw () ), ( "Londyn", europe__london () ), ( "Warszawa", europe__warsaw () ), ( "Nowy York", america__new_york () ), ( "Tokio", asia__tokyo () ) ]
        |> List.sortBy Tuple.first
        |> Dict.fromList


getTimeZoneForName : String -> Time.Zone
getTimeZoneForName key =
    case Dict.get key possibleTimeZones of
        Just val ->
            val

        Nothing ->
            defaultTimeZone


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "Unknown error"

        BadBody errorMessage ->
            errorMessage


addPrefixToUrl : String -> String
addPrefixToUrl url =
    "http://" ++ url


addPrefixToUrls : List String -> List String
addPrefixToUrls urls =
    urls |> List.map addPrefixToUrl


matches : String -> String -> Bool
matches regex =
    let
        validRegex =
            Regex.fromString regex
                |> Maybe.withDefault Regex.never
    in
    Regex.findAtMost 1 validRegex >> List.isEmpty >> not


defaultSeparators : List String
defaultSeparators =
    [ "\n", "\t", " ", "," ]


floatToMoney : Float -> String
floatToMoney num =
    format
        { decimals = 2
        , thousandSeparator = "."
        , decimalSeparator = ","
        , negativePrefix = "−"
        , negativeSuffix = ""
        , positivePrefix = ""
        , positiveSuffix = ""
        , zeroPrefix = ""
        , zeroSuffix = ""
        }
        num
