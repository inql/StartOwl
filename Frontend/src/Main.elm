module Main exposing (..)

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
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Task
import Time
import Types exposing (..)


type alias Model =
    { name : String
    , items : List Item
    }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "Dave" (List.repeat 2 sampleItemCategory)
    , Cmd.none
    )


type Msg
    = AddCategory Item
    | AddClock Item
    | Tick Time.Posix


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddCategory category ->
            ( { model | items = List.append model.items [ category ] }
            , Cmd.none
            )

        AddClock clock ->
            ( { model | items = List.append model.items [ clock ] }
            , Cmd.none
            )

        Tick newTime ->
            ( { model
                | items =
                    model.items
                        |> List.map
                            (\x ->
                                case x of
                                    CustomClock clock ->
                                        CustomClock (updateClock clock newTime)

                                    Section s ->
                                        Section s
                            )
              }
            , Cmd.none
            )


updateClock : Clock -> Time.Posix -> Clock
updateClock clock newTime =
    Clock clock.title clock.zone newTime


view : Model -> Html Msg
view model =
    div [ class "text-center" ]
        [ CDN.stylesheet
        , div []
            [ h1 []
                [ text "Hello"
                , Badge.badgeSuccess [ Spacing.ml1 ] [ text model.name ]
                ]
            ]
        , displayItems model.items
        , addOthers
        , addFooter
        ]


displayItems : List Item -> Html Msg
displayItems items =
    items |> List.map (\x -> Grid.row [] [ Grid.col [] [ displayItem x, br [] [] ] ]) |> Grid.container []


displayItem : Item -> Html Msg
displayItem item =
    case item of
        Section category ->
            displayCategory category

        CustomClock clock ->
            displayClock clock



-- TO DO


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


displayCategory : Category -> Html Msg
displayCategory category =
    Card.config [ Card.outlinePrimary, Card.align Text.alignXsCenter, Card.attrs [ Spacing.mb3 ] ]
        |> Card.headerH2 [ class "text-center" ]
            [ text category.name
            ]
        |> Card.block []
            [ category.tags |> List.map (\x -> Badge.pillInfo [ Spacing.ml1 ] [ text x ]) |> Block.titleH2 []
            , Block.custom <| Card.columns (listOfRecords category.records)
            ]
        |> Card.footer []
            [ text "Updated"
            ]
        |> Card.view


listOfRecords : List Record -> List (Card.Config Msg)
listOfRecords records =
    records |> List.map (\x -> displayRecord x)


displayRecord : Record -> Card.Config Msg
displayRecord record =
    Card.config [ Card.outlineSecondary, Card.align Text.alignXsCenter ]
        |> Card.header [ class "text-align" ]
            [ text record.title
            ]
        |> Card.block []
            [ Block.text [] [ text record.url ]
            , Block.link [ href record.url ] [ text record.url ]
            ]


addOthers : Html Msg
addOthers =
    div []
        [ Button.button [ Button.primary, Button.attrs [ Spacing.ml1, onClick (AddCategory sampleItemCategory) ] ] [ text "Add other" ]
        , Button.button [ Button.primary, Button.attrs [ Spacing.ml1, onClick (AddClock sampleItemClock) ] ] [ text "Add clock" ]
        ]


addFooter : Html Msg
addFooter =
    div []
        [ br [] []
        , br [] []
        ]
