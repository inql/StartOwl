module SiteItems.Items exposing (..)

import Bootstrap.Grid as Grid
import Html exposing (..)
import Json.Encode as E
import SiteItems.Categories exposing (..)
import SiteItems.Clocks exposing (..)


type Item
    = Section Category
    | CustomClock Clock


sampleItemClock : Item
sampleItemClock =
    CustomClock (Tuple.first (SiteItems.Clocks.init 0))


type Msg
    = CategoryMsg Int SiteItems.Categories.Msg
    | ClockMsg Int SiteItems.Clocks.Msg
    | ClockSubsMsg SiteItems.Clocks.Msg


type alias Model =
    List Item


init : ( Model, Cmd Msg )
init =
    let
        ( sampleItemCategory, catCmd ) =
            SiteItems.Categories.init 1
    in
    ( [ sampleItemClock ]
    , Cmd.batch [ Cmd.map (CategoryMsg 1) catCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    model
        |> List.map
            (\x ->
                case x of
                    CustomClock c ->
                        Sub.map ClockSubsMsg (SiteItems.Clocks.subscriptions c)

                    Section s ->
                        Sub.none
            )
        |> Sub.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryMsg id message ->
            let
                searchedMaybeItem =
                    model
                        |> filterCategories
                        |> List.filter
                            (\x ->
                                if x.id == id then
                                    True

                                else
                                    False
                            )
                        |> List.head

                searchedItem =
                    case searchedMaybeItem of
                        Just cat ->
                            cat

                        Nothing ->
                            sampleCategory -1

                ( updatedItem, cmdMsg ) =
                    SiteItems.Categories.update message searchedItem
            in
            ( model
                |> List.map
                    (\x ->
                        case x of
                            CustomClock c ->
                                CustomClock c

                            Section cat ->
                                if cat.id == id then
                                    Section updatedItem

                                else
                                    Section cat
                    )
            , Cmd.map (CategoryMsg id) cmdMsg
            )

        ClockMsg id message ->
            ( model
                |> List.map
                    (\x ->
                        case x of
                            CustomClock c ->
                                CustomClock (Tuple.first (SiteItems.Clocks.update message c))

                            Section cat ->
                                Section cat
                    )
            , Cmd.none
            )

        ClockSubsMsg message ->
            ( model
                |> List.map
                    (\x ->
                        case x of
                            CustomClock c ->
                                CustomClock (Tuple.first (SiteItems.Clocks.update message c))

                            Section cat ->
                                Section cat
                    )
            , Cmd.none
            )


filterCategories : List Item -> List Category
filterCategories items =
    items
        |> List.filterMap
            (\x ->
                case x of
                    Section cat ->
                        Just cat

                    CustomClock c ->
                        Nothing
            )


view : Model -> Html Msg
view model =
    displayItems model


displayItems : List Item -> Html Msg
displayItems items =
    items |> List.map (\x -> Grid.row [] [ Grid.col [] [ displayItem x, br [] [] ] ]) |> Grid.container []


displayItem : Item -> Html Msg
displayItem item =
    case item of
        Section category ->
            Html.map (CategoryMsg category.id) (SiteItems.Categories.view category)

        CustomClock clock ->
            Html.map (ClockMsg clock.id) (SiteItems.Clocks.view clock)


encodeItems : Model -> List E.Value
encodeItems model =
    model
        |> List.map
            (\x ->
                case x of
                    Section s ->
                        encodeCategory s

                    CustomClock c ->
                        encodeClock c
            )


decodeItems : String -> ( List Item, Cmd Msg )
decodeItems jsonStrong =
    init
