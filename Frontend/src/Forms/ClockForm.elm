module Forms.ClockForm exposing (..)

import Bootstrap.Button as Button
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import List.Selection exposing (Selection)
import Time
import TimeZone exposing (..)


type alias Model =
    { name : String
    , zone : Time.Zone
    }


type Msg
    = UpdateName String
    | UpdateTimeZone String
    | SubmitForm


init : ( Model, Cmd Msg )
init =
    ( Model "" defaultTimeZone
    , Cmd.none
    )


defaultTimeZone : Time.Zone
defaultTimeZone =
    europe__warsaw ()


possibleTimeZones : Dict String Time.Zone
possibleTimeZones =
    [ ( "Londyn", europe__london () ), ( "Warszawa", europe__warsaw () ), ( "Nowy York", america__new_york () ), ( "Tokio", asia__tokyo () ) ]
        |> List.sortBy Tuple.first
        |> Dict.fromList


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        UpdateName newName ->
            ( { model | name = newName }, Cmd.none, Nothing )

        UpdateTimeZone keyNewZone ->
            ( { model
                | zone =
                    case Dict.get keyNewZone possibleTimeZones of
                        Just val ->
                            val

                        Nothing ->
                            defaultTimeZone
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


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ input [ placeholder "name", value model.name, onInput UpdateName ] []
        , br [] []
        , br [] []
        , select [ onInput UpdateTimeZone ]
            (possibleTimeZones |> Dict.toList |> List.map (\x -> Tuple.first x) |> List.map (\x -> option [ value x ] [ text x ]))
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Submit" ]
        ]


validateNewClock : Model -> Bool
validateNewClock model =
    model.name |> String.isEmpty |> not
