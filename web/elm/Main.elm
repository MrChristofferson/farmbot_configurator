import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import Debug exposing (..)
import WebSocket

socket =
  "ws://localhost:4000/ws"

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL
type alias Model =
  { test : String }

init : (Model, Cmd Msg)
init =
  (Model "", Cmd.none)

-- UPDATE
type Msg =
  FromBot String

update : Msg -> Model -> (Model, Cmd Msg)
update msg thing =
  case msg of
    FromBot thing ->
      decode_json thing
      (Model thing, Cmd.none)

decode_json json =
  case decodeValue json of
    Ok val ->
      Debug.log val
    Err message ->
      Debug.log message

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen socket FromBot

-- VIEW
view : Model -> Html Msg
view model =
  div []
    []
