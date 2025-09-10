import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'home_page.dart'; // ДОБАВЛЯЕМ ИМПОРТ НОВОЙ СТРАНИЦЫ

const Color myCustomRed = Color(0xFFA31525);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        centerTitle: true,
        backgroundColor: myCustomRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Картинка
                Image.asset(
                  'assets/images/register.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // Заголовок
                const Text(
                  'Создайте аккаунт',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Поле имени
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Имя и фамилия',
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // Поле email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Поле пароля
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Пароль',
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Подтверждение пароля
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Подтвердите пароль',
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // Кнопка регистрации
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myCustomRed,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Ссылка на вход
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Уже есть аккаунт? Войдите'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Проверяем что все поля заполнены
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните все поля')),
        );
        return;
      }

      // Проверяем что пароли совпадают
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароли не совпадают')),
        );
        return;
      }

      // Проверяем email на валидность
      if (!_emailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите корректный email')),
        );
        return;
      }

      // УСПЕШНАЯ РЕГИСТРАЦИЯ - ПЕРЕХОД НА НОВУЮ СТРАНИЦУ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: _nameController.text,
            userEmail: _emailController.text,
            onLogout: () {
              // Логика выхода - возврат на страницу регистрации/входа
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}