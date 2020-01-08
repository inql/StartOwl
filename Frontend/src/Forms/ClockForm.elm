module Forms.ClockForm exposing (..)

import Bootstrap.Button as Button
import Dict exposing (Dict)
import Helpers exposing (defaultTimeZone, possibleTimeZones)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import List.Selection exposing (Selection)
import SiteItems.Clocks exposing (..)
import Time
import TimeZone exposing (..)


type alias Model =
    { name : String
    , zone : Time.Zone
    , clock : Maybe Clock
    }


type Msg
    = UpdateTimeZone String
    | SubmitForm
    | ClockMsg SiteItems.Clocks.Msg


init : ( Model, Cmd Msg )
init =
    ( Model "New clock" defaultTimeZone Nothing
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.clock of
        Nothing ->
            Sub.none

        Just c ->
            Sub.map ClockMsg (SiteItems.Clocks.subscriptions c)


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        UpdateTimeZone keyNewZone ->
            let
                newZone =
                    case Dict.get keyNewZone possibleTimeZones of
                        Just val ->
                            val

                        Nothing ->
                            defaultTimeZone
            in
            ( { model
                | zone = newZone
                , name = keyNewZone
                , clock = Just (Clock -1 keyNewZone newZone (Time.millisToPosix 0))
              }
            , Cmd.none
            , Nothing
            )

        SubmitForm ->
            case validateNewClock model of
                True ->
                    ( Tuple.first init, Cmd.none, Just model )

                _ ->
                    ( model, Cmd.none, Nothing )

        ClockMsg m ->
            case model.clock of
                Just cl ->
                    ( { model | clock = Just (Tuple.first (SiteItems.Clocks.update m cl)) }
                    , Cmd.none
                    , Nothing
                    )

                Nothing ->
                    ( model, Cmd.none, Nothing )


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ h1 [] [ text model.name ]
        , displayClock model.clock
        , select [ onInput UpdateTimeZone ]
            (possibleTimeZones |> Dict.toList |> List.map (\x -> Tuple.first x) |> List.map (\x -> option [ value x ] [ text x ]))
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Submit" ]
        ]


displayClock : Maybe Clock -> Html Msg
displayClock mclock =
    case mclock of
        Just clock ->
            Html.map ClockMsg (SiteItems.Clocks.displayClock clock)

        Nothing ->
            h2 [] [ text "--:--:--" ]


validateNewClock : Model -> Bool
validateNewClock model =
    model.name |> String.startsWith "New clock" |> not
