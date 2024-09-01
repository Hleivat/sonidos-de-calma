import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateuUserPage extends StatefulWidget{

  @override
  State createState (){
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateuUserPage>{

  late String email, password;
  final _formkey = GlobalKey<FormState>();
  String error='';

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ruidos De Calma"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Crear Usuario", style: TextStyle(color: Colors.black, fontSize: 24),),
          ),
          Offstage(
            offstage:error == '' ,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(error, style: TextStyle(color: Colors.red, fontSize: 16),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          butonCrearUsuario(),
        ],
      ),
    );
  }

  Widget formulario(){
    return Form(
      key: _formkey,
        child: Column(children: [
        buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
    ],));
  }

  Widget buildEmail(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(8),
          borderSide: new BorderSide(color: Colors.black)
        )
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value){
        email = value!;
      },
      validator: (value){
        if(value!.isEmpty){
          return "Este campo es obligatorio";
        }
        return null;        
      },
    );
  }

  Widget buildPassword(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(8),
          borderSide: new BorderSide(color: Colors.black)
        )
      ),
      obscureText: true,
      validator: (value){
        if(value!.isEmpty){
          return "Este campo es obligatorio";
        }
        return null;        
      },
      onSaved: (String? value){
        password = value!;
      },
    );
  }

  Widget butonCrearUsuario(){
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async{

          if(_formkey.currentState!.validate()){
            _formkey.currentState!.save();
            UserCredential? credenciales = await crear(email, password);
            if(credenciales !=null){
              if(credenciales.user !=null){
                 await credenciales.user!.sendEmailVerification();
                  Navigator.of(context).pop();

              }  
            }
          }
        },
      child: Text("Registrarse")
      ),  
    );
  }

  Future<UserCredential?> crear(String email, String password) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, 
          password: password);
      return userCredential;
      
    } on FirebaseAuthException catch(e){
      if(e.code == 'email-already-in-use'){
        //todocorreo en uso
        setState(() {
          error = 'el correo ya se encuenta en uso';
        });
      }
      if(e.code == 'weak-password'){
        //todo contraseña muy debil
        setState(() {
          error = 'contraseña muy debil';
        });
      }
    }
    return null;
  }
}
