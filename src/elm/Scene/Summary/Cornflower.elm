module Scene.Summary.Cornflower exposing
    ( background
    , hidden
    , visible
    )

import Css.Color as Color exposing (Color)
import Css.Style as Style
import Css.Transform as Transform
import Css.Transition as Transition
import Element
import Element.Flower.Cornflower as Cornflower
import Element.Palette as Palette
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (..)
import View.Landscape.RollingHills as Hills
import Window exposing (Window)


visible : Window -> Svg msg
visible =
    view Visible


hidden : Window -> Svg msg
hidden =
    view Hidden


background : Element.Color
background =
    Palette.blue5


type Visibility
    = Visible
    | Hidden


view : Visibility -> Window -> Svg msg
view visibility window =
    Svg.svg [ windowViewBox_ window, class "fixed z-1 top-0" ]
        (List.concat
            [ hills visibility window
            , flowers visibility window
            ]
        )


hills visibility window =
    [ hill "#b6b310" "#61cdfe" -600 1200 visibility window
    , hill "#d9d216" "#90dcff" -500 1000 visibility window
    , hill "#ECEC1F" "#b9f4ff" -400 800 visibility window
    , hill "#B6C123" "#61cdfe" -300 600 visibility window
    , hill "#038298" "#C5C520" -200 400 visibility window
    , hill "#6bb1ee" "#ECEC1F" -100 200 visibility window
    , hill "#038298" "#B6C123" 0 0 visibility window
    ]


hill : Color -> Color -> Float -> Int -> Visibility -> Window -> Svg msg
hill left right offset delay visibility window =
    let
        y =
            case visibility of
                Hidden ->
                    toFloat <| window.height // 2

                Visible ->
                    offset + 200

        translateStyles el =
            Svg.g
                [ Style.svg
                    [ Transition.transition "transform"
                        2000
                        [ Transition.cubicBezier 0 0 0 1
                        , Transition.delay delay
                        ]
                    , Style.transform [ Transform.translateY y ]
                    ]
                ]
                [ el ]
    in
    translateStyles <| Hills.doubleLayer window ( left, [] ) ( right, [] )


flowers visibility window =
    case visibility of
        Hidden ->
            []

        Visible ->
            [ cornflower window 250 1000 |> translated 0 -35
            , cornflower window 150 1500 |> translated -120 45
            , cornflower window 150 2000 |> translated 120 45
            ]


cornflower : Window -> Float -> Int -> Svg msg
cornflower window size delay =
    let
        offset =
            -size / 2
    in
    translated offset offset <|
        Svg.svg
            [ viewBox_ 0 0 size size
            , x_ <| toFloat window.width / 2
            , y_ <| toFloat window.height / 2 - 50
            , width_ size
            , height_ size
            ]
            [ Cornflower.animated delay ]
