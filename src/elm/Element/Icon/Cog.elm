module Element.Icon.Cog exposing (active, inactive)

import Css.Style as Style
import Css.Transition as Transition
import Element exposing (Element)
import Element.Icon as Icon
import Element.Palette as Palette
import Svg
import Svg.Attributes exposing (..)
import Utils.Svg as Svg



-- Cog


active : Element msg
active =
    icon Palette.white


inactive : Element msg
inactive =
    icon Palette.darkYellow


icon : Element.Color -> Element msg
icon color =
    Icon.el
        [ Svg.width_ 20
        , Svg.height_ 20
        , Svg.viewBox_ 0 0 20 20
        ]
        [ Svg.path
            [ Svg.fill_ color
            , Style.svg [ Transition.transition "fill" 500 [] ]
            , fillRule "evenodd"
            , d "M4.98 2.6c-.08-.41-.14-.82-.24-1.21-.05-.2-.01-.32.17-.4L7.15.04c.22-.1.35-.03.47.2.26.49.6.93 1.05 1.26.88.65 2.03.61 2.8-.14.35-.33.63-.73.9-1.13.13-.2.25-.28.47-.19l2.21.94c.22.09.24.23.17.45-.19.6-.26 1.22-.12 1.85.2.9.88 1.56 1.8 1.62a7.4 7.4 0 0 0 1.62-.13c.25-.04.41-.05.52.2l.9 2.2c.1.2.04.33-.17.45-.27.15-.54.33-.79.53-1.25 1.03-1.26 2.64-.02 3.67.26.21.53.4.81.56.19.11.27.22.18.42l-.93 2.25c-.09.2-.22.25-.45.18a3.7 3.7 0 0 0-1.64-.16c-1.13.17-1.87.97-1.88 2.13 0 .46.1.92.18 1.37.04.22.04.36-.18.45-.74.3-1.48.62-2.21.93-.22.1-.36.04-.47-.18a4.18 4.18 0 0 0-.46-.7c-1.11-1.39-2.76-1.38-3.86.02-.17.22-.32.46-.45.7-.09.17-.2.26-.39.18l-2.32-.98c-.2-.08-.19-.23-.13-.4.19-.62.25-1.24.11-1.87-.19-.91-.85-1.56-1.78-1.62-.56-.04-1.12.06-1.68.14-.22.04-.35.03-.44-.18l-.93-2.19c-.1-.24-.02-.37.2-.52.4-.25.8-.53 1.12-.87.82-.9.8-2.14-.05-3.01a5.7 5.7 0 0 0-1.04-.81c-.22-.15-.34-.28-.23-.54L1 4.88c.08-.19.22-.16.39-.13.5.08 1.04.23 1.54.17 1.35-.15 2-.96 2.05-2.33zM10.04 5a5 5 0 0 0-5.01 4.92 5 5 0 0 0 4.93 5.06A5 5 0 0 0 15 10.04 5 5 0 0 0 10.04 5z"
            ]
            []
        ]
