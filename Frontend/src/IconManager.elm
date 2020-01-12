module IconManager exposing (..)

import FeatherIcons
import Html exposing (Html)


deleteIcon : Html msg
deleteIcon =
    FeatherIcons.trash
        |> FeatherIcons.toHtml []


settingsIcon : Html msg
settingsIcon =
    FeatherIcons.settings
        |> FeatherIcons.toHtml []


editModeIcon : Html msg
editModeIcon =
    FeatherIcons.delete
        |> FeatherIcons.toHtml []
