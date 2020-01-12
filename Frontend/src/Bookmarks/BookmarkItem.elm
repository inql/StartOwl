module Bookmarks.BookmarkItem exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Helpers exposing (addPrefixToUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import IconManager as Icons


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
    | Remove


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

        Remove ->
            { model | id = -1 }


view : Model -> Html Msg
view model =
    case model.editMode of
        False ->
            a [ href (addPrefixToUrl model.url) ]
                [ Button.button [ Button.dark ] [ text model.name ]
                ]

        _ ->
            div [ style "overflow" "hidden" ]
                [ input [ placeholder "name", value model.name, onInput UpdateName ] []
                , br [] []
                , input [ placeholder "url", value model.url, onInput UpdateUrl ] []
                , br [] []
                , Button.button [ Button.danger, Button.small, Button.attrs [ onClick Remove ] ] [ Icons.deleteIcon ]
                ]
