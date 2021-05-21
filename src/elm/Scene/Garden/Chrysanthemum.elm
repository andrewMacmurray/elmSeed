module Scene.Garden.Chrysanthemum exposing (hills, view)

import Angle
import Arc2d exposing (Arc2d)
import Element exposing (..)
import Element.Palette as Palette
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d
import Polygon2d
import Scene.Garden.Flower as Flower
import Simple.Animation as Animation
import Svg exposing (Svg)
import Utils.Geometry as Geometry exposing (down)
import Utils.Svg as Svg
import View.Flower.Chrysanthemum as Chrysanthemum
import Window exposing (Window, vh, vw)



-- Description


description : String
description =
    "Chrysanthemums are native to Asia and Northeastern Europe, with the largest variety in China. They bloom early in Autumn, in many different colours and shapes. The Ancient Chinese used Chrysanthemum roots in pain relief medicine."



-- View


view : Flower.Config msg -> Element msg
view model =
    Flower.view
        { backdrop = Palette.purple
        , hills = hills model.window
        , flowers = flowers
        , description = description
        , isVisible = model.isVisible
        , onHide = model.onHide
        }


flowers : Element msg
flowers =
    row [ centerX ]
        [ el [ width (px 90), alignBottom, moveRight 10 ] (chrysanthemum 2200)
        , el [ width (px 150), moveUp 60 ] (chrysanthemum 2000)
        , el [ width (px 90), alignBottom, moveLeft 10 ] (chrysanthemum 2400)
        ]


chrysanthemum : Animation.Millis -> Element msg
chrysanthemum =
    html << Chrysanthemum.animated


hills : Window -> Svg msg
hills window =
    Svg.window window
        []
        [ roundHill Palette.pinkRed window
        , Geometry.mirror window (roundHill Palette.orange window)
        ]


centerRound_ w =
    Arc2d.from
        (Point2d.pixels (vw w / 4) (vh w))
        (Point2d.pixels (3 * (vw w / 4)) (vh w))
        (Angle.degrees 90)


centerPoint w =
    Arc2d.pointOn (centerRound_ w) 0.5


roundHill color window =
    Svg.g []
        [ Svg.arc2d [ Svg.fill_ color ] (roundHill_ window)
        ]


roundHill_ : Window -> Arc2d Pixels coordinates
roundHill_ window =
    Arc2d.translateBy (down -300)
        (Arc2d.from
            (Point2d.pixels -300 (vh window - 200))
            (centerPoint window)
            (Angle.degrees 90)
        )


roundHillBase_ window =
    Polygon2d.singleLoop
        [ Point2d.pixels -302 (vh window - 202)
        , centerPoint window
        , centerPoint window |> Point2d.translateBy (down 100)
        ]
