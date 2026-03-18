import /App/
import /HTML/
import /game_test/main/ as GameTest

init : GameTest.AppState =
  GameTest.fight_app_init()

def on_event(evt: GameTest.FightEvent, state: GameTest.AppState) -> GameTest.AppState:
  GameTest.on_event(evt, state)

def render(state: GameTest.AppState) -> HTML(GameTest.FightEvent):
  GameTest.fight_render(state)

main : App =
  app{GameTest.AppState, GameTest.FightEvent, init, render, on_event}
