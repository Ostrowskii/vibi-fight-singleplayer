# DungeonBend x Bend2: problemas identificados na migração do app para puro em Bend2

## 1. Bug de renderização ao alternar estados diferentes dentro do mesmo `App` e do mesmo root

### Contexto:

O menu e a dungeon compartilham a mesma "cena de jogo"/mesma página. Ao sair do menu e entrar na dungeon:

- o estado do jogo muda corretamente;
- a lógica de `start` funciona;
- mas a UI não troca de forma confiável;
- partes antigas da tela do menu continuam visíveis junto com partes novas da dungeon:

<img width="1314" height="651" alt="demo" src="https://gist.github.com/user-attachments/assets/f7d3cef1-f28d-4042-9b77-4edca0f5f298" />


### Diagnóstico

O problema não parece estar na lógica do jogo.

A evidência disso e que o estado mudou corretamente para o estado de run. O problema aparece na camada web do `App`, durante a troca entre duas árvores de UI muito diferentes dentro da mesma página.

### Hipótese técnica

O reconciler/patcher do runtime web do Bend2 não está lidando corretamente com a troca entre subtrees muito diferentes.

Em vez de remontar a nova tela de forma limpa, ele parece reaproveitar elementos demais do DOM anterior, deixando resíduos da tela antiga.

### Demanda para o time do Bend2

Precisamos de um runtime `App` que consiga atualizar corretamente a UI quando há transições entre telas com subtrees muito diferentes, sem manter resíduos da tela anterior.

---

## 2. Problema de navegação/estado entre páginas reais separadas

### Contexto

Uma alternativa ao problema anterior seria separar as telas como páginas reais distintas, por exemplo:

- `/menu`
- `/dungeon`

Basicamente um erro do saving do game.

### O que isso resolve

Esse modelo provavelmente evita o problema de reconciliação descrito acima, porque:

- a página antiga seria destruída;
- a nova página seria montada do zero;
- não haveria patch de subtree entre menu e dungeon.

### O que isso cria de novo

Ao separar em páginas reais, surge outro problema diferente:

- como transportar o estado entre paginas sem bridge manual?

Exemplos de estado afetado:

- ouro acumulado;
- upgrades;
- meta de sessão;
- seed;
- estado atual da run.

### Limite atual

Hoje o Bend2 não oferece, no fluxo que estamos usando, uma API browser-side suficiente para esse tipo de navegação com persistência de estado, sem voltar para infraestrutura manual fora do app puro em Bend.

### Demanda para o time do Bend2

Precisamos de alguma combinação destes recursos para suportar um fluxo multi-page ou multi-screen com estado confiável:

- persistencia browser-side exposta para Bend, como `localStorage` ou equivalente;
- API de navegação/roteamento;
- mecanismo oficial para passar/restaurar estado entre páginas/telas.

---

## 3. PRIORIDADE MAIS BAIXA: Falta de suporte oficial a swipe/pointer/touch

### Contexto

Hoje o caminho suportado para jogar é:

- teclado;
- Arrow Keys;
- WASD.

Isso permite prototipar a lógica do jogo. Mas não permite reproduzir a interação principal esperada para o projeto mobile.

### Demanda para o time do Bend2

Precisamos de suporte oficial a eventos de input mais adequados para jogos mobile/touch-first, incluindo pelo menos:

- swipe;
- pointer/touch;
- gestos básicos.

---

## Resumão

### Problema 1
Bug/limitação no reconciler do `App` ao trocar entre telas muito diferentes.

### Problema 2
Falta de mecanismo robusto para persistência/navegação de estado ao usar páginas reais separadas.

### Problema 3 (menor prioridade)
Falta de suporte oficial a swipe/pointer/touch para jogos.