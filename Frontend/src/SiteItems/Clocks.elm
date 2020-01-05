module SiteItems.Clocks exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Http
import Json.Encode as E
import Task
import Time
import TimeZone exposing (..)


type alias Clock =
    { id : Int
    , title : String
    , zone : Time.Zone
    , time : Time.Posix
    }


type alias Model =
    Clock


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


init : Int -> String -> Time.Zone -> ( Model, Cmd Msg )
init id name zone =
    ( Clock id name zone (Time.millisToPosix 0)
    , Task.perform AdjustTimeZone (Task.succeed zone)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick


view : Model -> Html Msg
view model =
    displayClock model


displayClock : Clock -> Html Msg
displayClock clock =
    let
        hour =
            String.fromInt (Time.toHour clock.zone clock.time)

        minute =
            String.fromInt (Time.toMinute clock.zone clock.time)

        second =
            String.fromInt (Time.toSecond clock.zone clock.time)
    in
    div []
        [ text clock.title
        , h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
        ]


encodeClock : Clock -> E.Value
encodeClock clock =
    E.object
        [ ( "id", E.int clock.id ) ]
