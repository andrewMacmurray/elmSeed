module Utils.Element exposing
    ( applyIf
    , class
    , disableTouch
    , empty
    , id
    , maybe
    , onClickIf
    , square
    , style
    , verticalGap
    )

import Element exposing (..)
import Element.Events exposing (onClick)
import Html.Attributes


maybe : (a -> Element msg) -> Maybe a -> Element msg
maybe toElement =
    Maybe.map toElement >> Maybe.withDefault none


id : String -> Attribute msg
id =
    htmlAttribute << Html.Attributes.id


verticalGap : Int -> Element msg
verticalGap size =
    el [ height (fillPortion size) ] none


square : Int -> List (Attribute msg) -> Element msg -> Element msg
square n =
    sized n n


sized : Int -> Int -> List (Attribute msg) -> Element msg -> Element msg
sized w h attrs =
    el (List.append [ width (px w), height (px h) ] attrs)


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


onClickIf : Bool -> msg -> Attribute msg
onClickIf condition msg =
    applyIf condition (onClick msg)


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf condition attr =
    if condition then
        attr

    else
        empty


empty : Attribute msg
empty =
    class ""


style : String -> String -> Attribute msg
style a b =
    htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    htmlAttribute << Html.Attributes.class