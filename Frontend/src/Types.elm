module Types exposing (..)

import Random
import Task
import Time


type alias Record =
    { url : String
    , title : String
    }


sampleRecord : Record
sampleRecord =
    Record "https://guide.elm-lang.org/types/type_aliases.html" "Custom Title"


type alias Category =
    { name : String
    , tags : List String
    , records : List Record
    }


sampleCategory : Category
sampleCategory =
    Category "Sample name" (List.repeat 2 "Tag") (List.repeat 5 sampleRecord)


type Item
    = Section Category
    | CustomClock Clock


sampleItemCategory : Item
sampleItemCategory =
    Section sampleCategory


sampleClock : Clock
sampleClock =
    Clock "Polska" Time.utc (Time.millisToPosix 0)


sampleItemClock : Item
sampleItemClock =
    CustomClock sampleClock


type alias Clock =
    { title : String
    , zone : Time.Zone
    , time : Time.Posix
    }
