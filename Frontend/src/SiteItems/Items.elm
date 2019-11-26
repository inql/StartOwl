module SiteItems.Items exposing (..)

import Bootstrap.Grid as Grid
import Html exposing (..)
import SiteItems.Categories exposing (..)
import SiteItems.Clocks exposing (..)


type Item
    = Section Category
    | CustomClock Clock


sampleItemCategory : Item
sampleItemCategory =
    Section (SiteItems.Categories.init 1)


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
    ( List.repeat 2 sampleItemCategory ++ [ sampleItemClock ], Cmd.none )


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
                            sampleCategory

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



-- TO DO
