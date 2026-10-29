# Brandão Timer

App Flutter (Android primeiro, iOS depois) de timer de intervalos para treino funcional. Uso pessoal, sem anúncios, sem conta e sem internet.

## Regras

- Toda lógica nova vem com testes unitários.
- Toda correção de bug vem com um teste de regressão que falha antes da correção.
- Antes de commitar: `dart format lib test`, `flutter analyze` sem avisos e `flutter test` passando.
- Textos da interface em português.

## Estrutura

- `lib/models/` modelos de dados (`Workout`).
- `lib/data/` persistência local (`shared_preferences`, JSON).
- `lib/screens/` telas.
- `lib/utils/` funções auxiliares.
- `test/` espelha a estrutura de `lib/`.
