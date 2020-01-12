module Bookmarks.BookmarksController exposing (..)

import Bookmarks.BookmarkItem exposing (..)
import Bootstrap.Navbar as Navbar
import Html exposing (..)
import Json.Decode as D
import Json.Encode as E


type alias Model =
    { bookmarks : List Bookmark
    }


type alias Bookmarks =
    Model


type Msg
    = BookmarkMsg Int Bookmarks.BookmarkItem.Msg


init : Model
init =
    Model []


addEmptyBookmark : Int -> Bool -> Bookmark
addEmptyBookmark id value =
    Bookmarks.BookmarkItem.Model id "New Bookmark" "" value


getNextId : Model -> Int
getNextId model =
    (model.bookmarks |> List.length) + 1


update : Msg -> Model -> Model
update msg model =
    case msg of
        BookmarkMsg id m ->
            { model
                | bookmarks =
                    model.bookmarks
                        |> List.filter (\x -> x.id == id)
                        |> List.map (\x -> Bookmarks.BookmarkItem.update m x)
                        |> List.filter (\x -> x.id > 0)
            }


toggleEditForBookmarks : Bool -> Model -> Model
toggleEditForBookmarks value model =
    { model | bookmarks = model.bookmarks |> List.map (\x -> { x | editMode = value }) }


addNewBookmark : Bool -> Model -> Model
addNewBookmark isEditMode model =
    { model | bookmarks = model.bookmarks ++ [ addEmptyBookmark (getNextId model) isEditMode ] }


view : Model -> List (Html Msg)
view model =
    model.bookmarks |> List.map (\x -> Html.map (BookmarkMsg x.id) (Bookmarks.BookmarkItem.view x))


encodeBookmarks : Model -> List E.Value
encodeBookmarks model =
    model.bookmarks |> List.map (\x -> encodeBookmark x)


encodeBookmark : Bookmark -> E.Value
encodeBookmark bookmark =
    E.object
        [ ( "id", E.int bookmark.id )
        , ( "name", E.string bookmark.name )
        , ( "url", E.string bookmark.url )
        ]


type alias SimplifiedBookmark =
    { id : Int
    , name : String
    , url : String
    }


decodeBookmarks : String -> Model
decodeBookmarks jsonString =
    case D.decodeString (D.list decodeBookmark) jsonString of
        Ok val ->
            Model (val |> List.map (\x -> Bookmarks.BookmarkItem.Model x.id x.name x.url False))

        Err _ ->
            Model []


decodeBookmark : D.Decoder SimplifiedBookmark
decodeBookmark =
    D.map3 SimplifiedBookmark
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "url" D.string)
