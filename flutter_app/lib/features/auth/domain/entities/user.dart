// Re-exporta a classe [User] definida em `core/auth/auth_service.dart`.
//
// A entidade User e definida uma unica vez no core e re-exportada aqui
// para manter a convencao de Clean Architecture sem duplicar codigo.
export 'package:egranja_flutter/core/auth/auth_service.dart' show User;
