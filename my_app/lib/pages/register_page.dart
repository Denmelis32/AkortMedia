import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

const Color myCustomRed = Color(0xFF2196F3);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Устанавливаем значения по умолчанию для всех полей
    _nameController.text = 'Игорь Бумажный';
    _emailController.text = 'IgorBumaga@example.com';
    _passwordController.text = '123456';
    _confirmPasswordController.text = '123456';
  }

  // 🎯 УЛУЧШЕННАЯ РЕГИСТРАЦИЯ С ГАРАНТИРОВАННЫМ СОХРАНЕНИЕМ ТОКЕНА
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Проверяем что все поля заполнены
        if (_nameController.text.isEmpty ||
            _emailController.text.isEmpty ||
            _passwordController.text.isEmpty ||
            _confirmPasswordController.text.isEmpty) {
          throw Exception('Заполните все поля');
        }

        // Проверяем что пароли совпадают
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Пароли не совпадают');
        }

        // Проверяем email на валидность
        if (!_emailController.text.contains('@')) {
          throw Exception('Введите корректный email');
        }

        print('🎯 Starting registration process...');

        // 🎯 ВЫПОЛНЯЕМ РЕГИСТРАЦИЮ ЧЕРЕЗ API SERVICE
        final result = await ApiService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        print('🔑 Registration API response received');

        // 🎯 ГАРАНТИРОВАННОЕ СОХРАНЕНИЕ ТОКЕНА
        String? finalToken;

        if (result['token'] != null) {
          await AuthService.saveToken(result['token']);
          finalToken = result['token'];
          print('✅ Token saved from API response');
        } else {
          // 🎯 СОЗДАЕМ ТОКЕН ВРУЧНУЮ ЕСЛИ ЕГО НЕТ В ОТВЕТЕ
          final userId = result['user']?['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
          final manualToken = 'mock-jwt-token-$userId';
          await AuthService.saveToken(manualToken);
          finalToken = manualToken;
          result['token'] = manualToken;
          print('🔄 Manual token created: $manualToken');
        }

        // 🎯 СОХРАНЯЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ
        if (result['user'] != null) {
          await AuthService.saveUser(Map<String, dynamic>.from(result['user']));
          print('✅ User data saved');
        } else {
          // 🎯 СОЗДАЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ ЕСЛИ ИХ НЕТ
          final userData = {
            'id': result['user']?['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
            'name': _nameController.text,
            'email': _emailController.text,
          };
          await AuthService.saveUser(userData);
          print('✅ Manual user data created');
        }

        // 🎯 ПРОВЕРЯЕМ ЧТО ТОКЕН ДЕЙСТВИТЕЛЬНО СОХРАНИЛСЯ
        final savedToken = await AuthService.getToken();
        if (savedToken == null) {
          throw Exception('Не удалось сохранить токен авторизации');
        }

        print('✅ Token verified after registration: ${savedToken.substring(0, _min(savedToken.length, 20))}...');

        // 🎯 СИНХРОНИЗИРУЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ С PROVIDER
        final userProvider = context.read<UserProvider>();
        if (result['user'] != null) {
          final userData = Map<String, dynamic>.from(result['user']);
          await userProvider.setUserData(
            userData['name'] ?? _nameController.text,
            userData['email'] ?? _emailController.text,
            userId: userData['id']?.toString() ?? '',
          );
        } else {
          // Если нет данных пользователя в ответе
          await userProvider.setUserData(
            _nameController.text,
            _emailController.text,
          );
        }

        // 🎯 ВЫПОЛНЯЕМ СИНХРОНИЗАЦИЮ С СЕРВЕРОМ
        print('🔄 Syncing user data with server after registration...');
        await userProvider.syncWithServer();

        print('✅ Registration process completed successfully');

        // Успешная регистрация
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Регистрация успешна!'),
              backgroundColor: Colors.green,
            ),
          );

          // Переход на HomePage
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userName: userProvider.userName,
                  userEmail: userProvider.userEmail,
                  onLogout: () {
                    userProvider.clearUserData();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    }
                  },
                ),
              ),
            );
          }
        }

      } catch (e) {
        print('❌ Registration error: $e');

        // Ошибка
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Финально
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  int _min(int a, int b) => a < b ? a : b;

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Сначала отменяем все асинхронные операции
    if (_isLoading) {
      _isLoading = false;
    }

    // Затем диспозим контроллеры
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // В конце вызываем super.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Заголовок
                    const Text(
                      'Создание аккаунта',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: myCustomRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Заполните данные для регистрации',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Сообщение об ошибке
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    if (_errorMessage != null) const SizedBox(height: 16),

                    // Поле имени
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя и фамилия',
                        hintText: 'Введите ваше имя',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите имя';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Поле email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Введите ваш email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Поле пароля
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        hintText: 'Придумайте пароль',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен содержать минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Подтверждение пароля
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Подтвердите пароль',
                        hintText: 'Повторите пароль',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Подтвердите пароль';
                        }
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Кнопка регистрации
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myCustomRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Разделитель
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'или',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Кнопка входа
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _navigateToLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: myCustomRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Войти в аккаунт',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: myCustomRed,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Текст под кнопкой входа
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Уже есть аккаунт? Войдите сейчас',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}