import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController handle = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode handleFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    // Listeners para actualizar el estado cuando los campos ganan/pierden foco
    emailFocus.addListener(() => setState(() {}));
    handleFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailFocus.dispose();
    handleFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void register() async {
    setState(() {
      isLoading = true;
      error = null; // Limpiar error anterior
    });

    final success = await AuthService.register(
      email: email.text,
      handle: handle.text,
      password: password.text,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      setState(() {
        error = 'Registration failed. Please try again.';
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    bool isPassword = false,
  }) {
    final bool isFocused = focusNode.hasFocus;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color.fromRGBO(255, 56, 93, 1),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar completamente transparente/blanco
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(255, 56, 93, 1),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 40), // Espacio superior
                // Contenedor principal centrado
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título con gradiente
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Color.fromRGBO(255, 56, 93, 1),
                            Color.fromRGBO(255, 56, 93, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Mensaje de bienvenida
                      Text(
                        'Join INMAX today!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: 32),

                      // Campo de email
                      _buildTextField(
                        controller: email,
                        focusNode: emailFocus,
                        placeholder: 'Email',
                      ),

                      // Campo de handle
                      _buildTextField(
                        controller: handle,
                        focusNode: handleFocus,
                        placeholder: 'Handle',
                      ),

                      // Campo de contraseña
                      _buildTextField(
                        controller: password,
                        focusNode: passwordFocus,
                        placeholder: 'Password',
                        isPassword: true,
                      ),

                      SizedBox(height: 8),

                      // Mensaje de error (si existe)
                      if (error != null)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Botón de registro
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: GestureDetector(
                          onTap: isLoading ? null : register,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isLoading
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        Color.fromRGBO(255, 56, 93, 1),
                                        Color.fromRGBO(255, 56, 93, 0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              color: isLoading
                                  ? Color.fromRGBO(255, 56, 93, 0.6)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Enlace de login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color.fromRGBO(255, 56, 93, 1),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 56, 93, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40), // Espacio inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}
