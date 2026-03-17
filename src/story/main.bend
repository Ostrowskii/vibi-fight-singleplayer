import /App/
import /HTML/

type StoryState {
  story_state{}
}

type StoryEvent {
  evt_ignore{}
}

init : StoryState =
  story_state{}

def on_event(evt: StoryEvent, state: StoryState) -> StoryState:
  state

def render(state: StoryState) -> HTML(StoryEvent):
  <main class="story-page">
    <style>{text{css()}}</style>
    <section class="story-card">
      <div class="story-eyebrow">{text{"Play Story"}}</div>
      <h1 class="story-title">{text{"Campanha em construcao"}}</h1>
      <p class="story-copy">{text{"Essa rota vai usar a mesma chamada de fight do modo Play, com skills compartilhadas e itens entrando depois."}}</p>
      <div class="story-facts">
        <div class="story-fact">
          <span class="story-fact__label">{text{"HP base"}}</span>
          <strong class="story-fact__value">{text{"50"}}</strong>
        </div>
        <div class="story-fact">
          <span class="story-fact__label">{text{"Skills atuais"}}</span>
          <strong class="story-fact__value">{text{"6"}}</strong>
        </div>
      </div>
      <div class="story-skill-row">
        {_story_skill_card("Me1", "Melee")}
        {_story_skill_card("Me2", "Melee")}
        {_story_skill_card("Me3", "Melee")}
        {_story_skill_card("Me4", "Melee")}
        {_story_skill_card("Ma1", "Mage")}
        {_story_skill_card("Ma2", "Mage")}
      </div>
      <div class="story-actions">
        <a class="story-link" href="../">{text{"Voltar ao menu"}}</a>
        <a class="story-link story-link--primary" href="../play/">{text{"Ir para Play"}}</a>
      </div>
    </section>
  </main>

def _story_skill_card(name: String, class_name: String) -> HTML(StoryEvent):
  <div class="story-skill">
    <span class="story-skill__name">{text{name}}</span>
    <span class="story-skill__class">{text{class_name}}</span>
  </div>

def css() -> String:
  ""
  ++ ":root{--bg:#d3bb94;--panel:#efe2c6;--card:#f7ecd3;--text:#2a2115;--muted:#6b593c;--border:#7a613c;--button:#966320;--button-alt:#b58a43;}*{box-sizing:border-box;}html,body{margin:0;width:100%;height:100%;background:var(--bg);color:var(--text);font-family:'Trebuchet MS','Segoe UI',sans-serif;}body{min-height:100svh;}a{text-decoration:none;}"
  ++ ".story-page{min-height:100svh;padding:32px 20px;display:grid;place-items:center;}.story-card{width:min(100%,860px);display:grid;gap:18px;padding:28px;background:var(--panel);border:1px solid var(--border);}.story-eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);font-weight:800;}.story-title{margin:0;font-size:42px;line-height:1;}.story-copy{margin:0;color:var(--muted);line-height:1.6;}.story-facts{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;}.story-fact{padding:14px;background:var(--card);border:1px solid #bda173;}.story-fact__label{display:block;font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);}.story-fact__value{display:block;margin-top:6px;font-size:28px;}.story-skill-row{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;}.story-skill{padding:14px;background:var(--card);border:1px solid #bda173;display:grid;gap:6px;justify-items:center;text-align:center;}.story-skill__name{font-weight:800;}.story-skill__class{font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);}.story-actions{display:flex;gap:12px;flex-wrap:wrap;}.story-link{display:inline-flex;align-items:center;justify-content:center;min-width:140px;padding:11px 15px;border-radius:999px;background:var(--button-alt);color:#fff8eb;font-weight:800;}.story-link--primary{background:var(--button);}@media (max-width:720px){.story-page{padding:20px 14px;}.story-title{font-size:34px;}.story-facts,.story-skill-row{grid-template-columns:1fr 1fr;}}"

main : App =
  app{StoryState, StoryEvent, init, render, on_event}
