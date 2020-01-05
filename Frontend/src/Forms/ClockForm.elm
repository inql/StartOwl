module Forms.ClockForm exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Dropdown as Dropdown
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Time
import TimeZone exposing (..)


type alias Model =
    { name : String
    , zone : Time.Zone
    , dropDownState : Dropdown.State
    }


type Msg
    = UpdateName String
    | UpdateTimeZone Time.Zone
    | SubmitForm
    | MyDrop1Msg Dropdown.State


init : ( Model, Cmd Msg )
init =
    ( Model "" defaultTimeZone Dropdown.initialState
    , Cmd.none
    )


defaultTimeZone : Time.Zone
defaultTimeZone =
    europe__warsaw ()


possibleTimeZones : List Time.Zone
possibleTimeZones =
    [ europe__london (), europe__warsaw (), america__new_york () ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Dropdown.subscriptions model.dropDownState MyDrop1Msg ]


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        UpdateName newName ->
            ( { model | name = newName }, Cmd.none, Nothing )

        UpdateTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none, Nothing )

        SubmitForm ->
            ( Tuple.first init, Cmd.none, Just model )

        MyDrop1Msg state ->
            ( { model | dropDownState = state }
            , Cmd.none
            , Nothing
            )


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ input [ placeholder "name", value model.name, onInput UpdateName ] []
        , br [] []
        , br [] []
        , div []
            [ Dropdown.dropdown
                model.dropDownState
                { options = []
                , toggleMsg = MyDrop1Msg
                , toggleButton =
                    Dropdown.toggle [ Button.primary ] [ text "Select time zone" ]
                , items =
                    [ Dropdown.buttonItem [ onClick (UpdateTimeZone (europe__warsaw ())) ] [ text "Polska" ]
                    , Dropdown.buttonItem [ onClick (UpdateTimeZone (america__new_york ())) ] [ text "New York" ]
                    ]
                }

            -- etc
            ]
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Submit" ]
        ]
