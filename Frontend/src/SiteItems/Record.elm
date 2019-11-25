module SiteItems.Record exposing (Record, sampleRecord)


type alias Record =
    { url : String
    , title : String
    }


sampleRecord : Record
sampleRecord =
    Record "https://guide.elm-lang.org/types/type_aliases.html" "Custom Title"
