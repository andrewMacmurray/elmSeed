module Scene.Garden.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Scene.Garden.Cornflower.Flowers as Flowers
import Scene.Garden.Cornflower.Hills as Hills
import Shape exposing (Shape)
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers