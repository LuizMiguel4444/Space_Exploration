<h1 align="center">Nasa_Project</h1>

<p align="center">
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white"/>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
</p>

- [📑 Sobre o projeto](#-sobre)
- [📂 Estrutura do projeto](#-estrutura-do-projeto)
- [🚀 Iniciando](#-iniciando)

## 📑 Sobre
Projeto desenvolvido para a disciplina de Poo do curso de Sistemas de Informação.
O projeto se trata de um aplicativo que tem como objetivo proporcionar ao usuário a oportunidade de observar e ver detalhes a cerca de dados disponibilizados pela Nasa a partir da [api](https://apod.nasa.gov/apod/astropix.html). O aplicativo apresenta diversas imagens do universo ao usuário, bem como detalhes e a possibilidade de favoritar, fazer download e explorar cada uma delas. O código fonte foi desenvolvido utilizando a linguagem dart e o framework Flutter.

## 📂 Estrutura do projeto
```
Nasa_Project
├─ lib
│  ├─ controllers
│  │  ├─ favorite_controller.dart
│  │  ├─ image_day_controller.dart
│  │  ├─ language_controller.dart
│  │  ├─ navBar_controller.dart
│  │  ├─ space_controller.dart
│  │  └─ theme_controller.dart
│  │
│  ├─ data
│  │  └─ dataService.dart
│  │
│  ├─ models
│  │  └─ nasa_image.dart
│  │
│  ├─ views
│  │  ├─ favorite_page.dart
│  │  ├─ home_page.dart
│  │  ├─ image_day_page.dart
│  │  └─ image_details_page.dart
│  │
│  ├─ main.dart
│  └─ translations.dart
│
├─ pubspec.lock
└─ pubspec.yaml

```


## 🚀 Iniciando

### Passo 1: Clone o repositório
```git clone https://github.com/LuizMiguel4444/Mini_Projeto_Poo1```

### Passo 2: Navegue até o repositório
```cd Mini_Projeto_Poo1```

### Passo 3: Baixe as dependências necessárias
```flutter pub get```

### Passo 4: Execute o projeto: 
```flutter run```
