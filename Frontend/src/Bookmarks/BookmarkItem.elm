module Bookmarks.BookmarkItem exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { id : Int
    , name : String
    , url : String
    , editMode : Bool
    }


type alias Bookmark =
    Model


type Msg
    = UpdateName String
    | UpdateUrl String


init : Int -> String -> String -> Model
init id name url =
    Model id name url False


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateName newName ->
            { model | name = newName }

        UpdateUrl newUrl ->
            { model | url = newUrl }


view : Model -> Html Msg
view model =
    case model.editMode of
        False ->
            a [ href model.url ]
                [ Button.button [ Button.dark ] [ text model.name ]
                ]

        _ ->
            div []
                [ input [ placeholder "name", value model.name, onInput UpdateName ] []
                , br [] []
                , input [ placeholder "url", value model.url, onInput UpdateUrl ] []
                ]
