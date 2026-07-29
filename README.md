Backend Project Tree

backend/
|
|-- bin/
|   └── server.dart
|
|-- lib/
|   |-- config/
|   |   |-- app_config.dart
|   |   |-- database.dart
|   |   |-- env.dart
|   |   └── websocket.dart
|   |-- core/
|   |   |-- middleware/
|   |   |   |-- auth_middleware.dart
|   |   |   |-- cors_middleware.dart
|   |   |   └── logger_middleware.dart
|   |   |-- security/
|   |   |   |-- bcrypt_helper.dart
|   |   |   └── jwt_helper.dart
|   |   |-- exceptions/
|   |   └── utils/
|   |-- models/
|   |   |-- user_model.dart
|   |   |-- room_model.dart
|   |   |-- message_model.dart
|   |   └── response_model.dart
|   |-- repositories/
|   |   |-- user_repository.dart
|   |   |-- room_repository.dart
|   |   └── message_repository.dart
|   |-- services/
|   |   |-- auth_service.dart
|   |   |-- user_service.dart
|   |   |-- room_service.dart
|   |   |-- message_service.dart
|   |   └── websocket_service.dart
|   |-- controllers/
|   |   |-- auth_controller.dart
|   |   |-- user_controller.dart
|   |   |-- room_controller.dart
|   |   └── message_controller.dart
|   |-- routes/
|   |   |-- auth_routes.dart
|   |   |-- user_routes.dart
|   |   |-- room_routes.dart
|   |   └── message_routes.dart
|   └── app.dart
|-- .env
|-- pubspec.yaml
└── README.md
