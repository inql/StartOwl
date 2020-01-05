module SiteItems.Items exposing (..)

import Bootstrap.Grid as Grid
import Html exposing (..)
import Json.Decode as D
import Json.Encode as E
import SiteItems.Categories exposing (..)
import SiteItems.Clocks exposing (..)
import Time exposing (..)


type Item
    = Section Category
    | CustomClock Clock


type Msg
    = CategoryMsg Int SiteItems.Categories.Msg
    | ClockMsg Int SiteItems.Clocks.Msg
    | ClockSubsMsg SiteItems.Clocks.Msg


type alias Model =
    { categories : List Category
    , clocks : List Clock
    }


init : ( Model, Cmd Msg )
init =
    let
        ( sampleItemCategory, catCmd ) =
            SiteItems.Categories.init 1
    in
    ( Model [] []
    , Cmd.batch [ Cmd.map (CategoryMsg 1) catCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    model.clocks
        |> List.map (\x -> Sub.map ClockSubsMsg (SiteItems.Clocks.subscriptions x))
        |> Sub.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryMsg id message ->
            let
                searchedMaybeItem =
                    model.categories
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
            ( { model
                | categories =
                    model.categories
                        |> List.map
                            (\cat ->
                                if cat.id == id then
                                    updatedItem

                                else
                                    cat
                            )
                        |> List.filter (\x -> x.status /= SiteItems.Categories.Delete)
              }
            , Cmd.map (CategoryMsg id) cmdMsg
            )

        ClockMsg id message ->
            ( { model
                | clocks =
                    model.clocks
                        |> List.map
                            (\x ->
                                if x.id == id then
                                    Tuple.first (SiteItems.Clocks.update message x)

                                else
                                    x
                            )
              }
            , Cmd.none
            )

        ClockSubsMsg message ->
            ( { model
                | clocks =
                    model.clocks
                        |> List.map (\x -> Tuple.first (SiteItems.Clocks.update message x))
              }
            , Cmd.none
            )


getNextId : Model -> Int
getNextId model =
    case getItemListWithId model |> List.reverse |> List.head of
        Just x ->
            Tuple.first x + 1

        Nothing ->
            1


addNewCategory : String -> List String -> Model -> Model
addNewCategory name tags model =
    { model | categories = model.categories ++ [ Category (getNextId model) name tags [] Loading ] }


addNewClock : String -> Time.Zone -> Model -> ( Model, Cmd Msg )
addNewClock name timezone model =
    let
        ( newClock, cmd ) =
            SiteItems.Clocks.init (getNextId model) name timezone
    in
    ( { model | clocks = model.clocks ++ [ newClock ] }, Cmd.map (ClockMsg newClock.id) cmd )


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


getItemListWithId : Model -> List ( Int, Item )
getItemListWithId model =
    let
        categoriesWithId =
            model.categories |> List.map (\x -> ( x.id, Section x ))

        clocksWithId =
            model.clocks |> List.map (\x -> ( x.id, CustomClock x ))
    in
    categoriesWithId ++ clocksWithId |> List.sortBy Tuple.first


getItemList : Model -> List Item
getItemList model =
    getItemListWithId model |> List.map (\x -> Tuple.second x)


view : Model -> Html Msg
view model =
    displayItems (getItemList model)


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


encodeCategories : Model -> List E.Value
encodeCategories model =
    model.categories
        |> List.map
            (\x -> encodeCategory x)


encodeClocks : Model -> List E.Value
encodeClocks model =
    model.clocks |> List.map (\x -> encodeClock x)


type alias SimplifiedCategory =
    { id : Int
    , name : String
    , tags : List String
    }


decodeItems : String -> ( Model, Cmd Msg )
decodeItems jsonString =
    case D.decodeString decodeCategories jsonString of
        Ok val ->
            ( Model (val |> List.map (\x -> Category x.id x.name x.tags [] Loading)) [], Cmd.none )

        Err _ ->
            ( Model [] [], Cmd.none )


decodeCategories : D.Decoder (List SimplifiedCategory)
decodeCategories =
    D.list decodeCat


decodeCat : D.Decoder SimplifiedCategory
decodeCat =
    D.map3 SimplifiedCategory
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "tags" (D.list D.string))
