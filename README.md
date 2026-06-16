# mobile_arquitetura_01
# 🛍️ Flutter Products App

Aplicação mobile desenvolvida em **Flutter** que consome a API [DummyJSON](https://dummyjson.com) para exibir e gerenciar produtos, com autenticação de usuário e arquitetura em camadas.

---

## Funcionalidades

- **Autenticação** — login com usuário e senha via API, sessão mantida em memória e logout com confirmação
- **Listagem de produtos** — lista com imagem, título e preço, carregada via `GET /products`
- **Detalhes do produto** — tela dedicada com nome, preço, descrição, categoria e imagem
- **CRUD completo** — criação, edição e exclusão de produtos com feedback visual
- **Favoritos** — marcar e desmarcar produtos como favoritos durante a sessão
- **Cache local** — fallback automático para dados em cache quando a API não está disponível
- **Tratamento de erros** — mensagens amigáveis para falhas de rede, timeout e credenciais inválidas

---

## Arquitetura

O projeto segue uma **arquitetura em camadas**, com responsabilidades bem definidas:

```
lib/
│   main.dart
│
├── core/
│   ├── network/
│   │   └── api_client.dart           # NetworkException tipada
│   └── session/
│       └── session_manager.dart      # Gerenciamento de sessão em memória
│
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   ├── product_remote_datasource.dart
│   │   └── product_local_datasource.dart
│   ├── models/
│   │   ├── auth_user_model.dart
│   │   └── product_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── product_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── auth_user.dart
│   │   └── product.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── product_repository.dart
│
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   ├── product_list_page.dart
    │   ├── product_detail_page.dart
    │   └── product_form_page.dart
    ├── viewmodels/
    │   ├── auth_viewmodel.dart
    │   ├── product_viewmodel.dart
    │   ├── product_state.dart
    │   ├── product_form_viewmodel.dart
    │   └── favorites_viewmodel.dart
    └── widgets/
        └── product_tile.dart
```

### Responsabilidades por camada

| Camada | Responsabilidade |
|--------|-----------------|
| `domain` | Entidades e contratos (interfaces) dos repositórios |
| `data` | Implementação dos repositórios, modelos e datasources (IO) |
| `core` | Utilitários transversais: exceções e sessão |
| `presentation` | ViewModels (estado) e telas (UI) |

---

## API

O projeto consome a [DummyJSON](https://dummyjson.com). Os endpoints utilizados são:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/auth/login` | Autenticação do usuário |
| `GET` | `/products?limit=30` | Listagem de produtos |
| `GET` | `/products/{id}` | Detalhes de um produto |
| `POST` | `/products/add` | Criação de produto |
| `PUT` | `/products/{id}` | Atualização de produto |
| `DELETE` | `/products/{id}` | Exclusão de produto |

> **Credencial de teste:** `emilys` / `emilyspass`

---

## Como executar

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) — versão 3.x ou superior
- Dart SDK incluso no Flutter
- Dispositivo físico ou emulador configurado

### Passos

```bash
# Clone o repositório
git clone https://github.com/Vitor-Calliari/mobile_arquitetura_01.git

# Acesse a pasta do projeto
cd seu-repositorio

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

---

## Dependências

| Pacote | Uso |
|--------|-----|
| [`http`](https://pub.dev/packages/http) | Requisições HTTP à API DummyJSON |

---

## Gerenciamento de estado

O projeto utiliza **`ChangeNotifier`** com `addListener` / `setState` manual, sem pacotes externos de gerenciamento de estado. Cada ViewModel estende `ChangeNotifier` e notifica a tela via `notifyListeners()` sempre que o estado muda.

Os estados da listagem são representados por uma `sealed class`:

```dart
sealed class ProductState {}

class ProductLoading extends ProductState {}
class ProductSuccess extends ProductState { ... }
class ProductError extends ProductState { ... }
```

---

## Autenticação e sessão

Após o login bem-sucedido, o `SessionManager` (singleton) armazena o `AuthUser` com o `accessToken` retornado pela API. O token é incluído automaticamente no header `Authorization: Bearer <token>` em todas as requisições de produto.

O logout limpa a sessão e remove toda a pilha de navegação, impedindo o retorno à tela de produtos sem novo login.

---

## Licença

Este projeto foi desenvolvido para fins acadêmicos.
