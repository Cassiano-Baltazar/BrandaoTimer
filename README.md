# Brandão Timer

Timer de intervalos para treino funcional, sem anúncios.

Cadastre seus treinos (quantidade de exercícios, tempo de cada exercício, descanso entre exercícios, quantidade de séries e descanso entre séries) e escolha qual fazer.

## Desenvolvimento

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Instalar no Android

Cada push no `main` gera uma release no GitHub com o arquivo `app-release.apk`. Abra a página de releases no celular, baixe o APK e toque nele para instalar (o Android vai pedir para permitir instalação desta fonte). Para atualizar, instale o APK novo por cima: os treinos salvos continuam.

Todo push também roda os testes e gera o APK como artefato do GitHub Actions.

## Instalar no iPhone

Cada release também traz `BrandaoTimer-unsigned.ipa`, o app de iPhone sem assinatura. Para instalar, use o [Sideloadly](https://sideloadly.io) (Windows ou Mac): conecte o iPhone por cabo, arraste o IPA, entre com seu Apple ID e clique em Start. No iPhone, confie no app em Ajustes > Geral > VPN e Gerenciamento de Dispositivos e ligue o Modo de Desenvolvedor. Com Apple ID grátis, o app precisa ser reinstalado a cada 7 dias.
