module Category  exposing (..)

import Types exposing(Category, WebsiteRecord)

import WebsiteRecordForm exposing (..)


import Html exposing (Html, button, div, h1, text, br)
import Html.Events exposing (onClick)


import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Button as Button

type alias Model =
    Category

type Msg =
    AddTag String

init : Model
init = Category ["abc","qwe"] (List.repeat 2 WebsiteRecordForm.init)


update : Msg -> Model -> Model
update msg model =
    model

view : Model -> Html Msg
view model =
    div [] [
        model.tags |> List.map (\x -> text x) |> div []
    ]


