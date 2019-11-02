module WebsiteRecordForm exposing (..)

import Types exposing (WebsiteRecord)

import Html exposing (Html, button, div, h1, text, br)
import Html.Events exposing (onClick)


import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Button as Button
-- MODEL


type alias Model =
    WebsiteRecord


init : Model
init =
    WebsiteRecord "Ecosia" "Plant trees" "https://ecosia.org"



-- UPDATE


type Msg =
     UpdateUrl String
    | UpdateDescription String
    | UpdateTitle String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateUrl newUrl -> {model | url = newUrl}
        UpdateDescription newDesc -> {model | description = newDesc}
        UpdateTitle newTitle -> {model | title = newTitle}

view : Model -> Html Msg
view model =
    div []
        [ InputGroup.config
            (InputGroup.text [ Input.placeholder "website"
            , Input.onInput UpdateTitle
            , Input.value model.title
            ])
            |> InputGroup.view
        , br [] []
        , InputGroup.config
             (InputGroup.text [ Input.placeholder "description"
             , Input.onInput UpdateDescription
             , Input.value model.description
             ])
            |> InputGroup.view
        , br [] []
        , InputGroup.config
            (InputGroup.text [ Input.placeholder "website"
            , Input.onInput UpdateUrl
            , Input.value model.url
            ])
           |> InputGroup.view
        , br [] []
        ]