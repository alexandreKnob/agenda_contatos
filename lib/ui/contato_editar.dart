import 'dart:io';
import 'package:agenda_contatos/helpers/contato_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ContatoEditar extends StatefulWidget {

  final Contato contato;
  ContatoEditar({this.contato}); // entre chave, parêmetro opcional

  @override
  _ContatoEditarState createState() => _ContatoEditarState();
}

class _ContatoEditarState extends State<ContatoEditar> {

  ContatoHelper helper = ContatoHelper();
  final _nomeFocus = FocusNode();

  // _contatoEditado do tip contato
  Contato _contatoEditado;
  bool _formularioEditado = false;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _foneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //vamos tetar se o contato é vazio, acesso o contato da outra classe
    // com widget.contato, o widget é o ContatoEditar.
    if (widget.contato == null) {
      _contatoEditado = Contato(); // é um novo contato
    } else {
      _contatoEditado = Contato.fromMap(widget.contato.toMap());

      // joga para os controllers o dados recebidos.
      _nomeController.text  = _contatoEditado.nome;
      _emailController.text = _contatoEditado.email;
      _foneController.text  = _contatoEditado.fone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _verificaConfirmacao,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_contatoEditado.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_contatoEditado.nome != null && _contatoEditado.nome.isNotEmpty){
              Navigator.pop(context, _contatoEditado);
            } else {
              FocusScope.of(context).requestFocus(_nomeFocus);
            }
            //helper.atualizaContato(_contatoEditado); // para atualizar aqui caso queira.
            //Navigator.pop(context);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _contatoEditado.img != null ?
                        FileImage(File(_contatoEditado.img)) :
                        AssetImage("imagens/pessoa.jpg"),
                        fit: BoxFit.cover,
                      )),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                    if (file==null) return;
                    setState(() {
                      _contatoEditado.img = file.path;
                    });
                  });
                },

              ),

              TextField(
                focusNode: _nomeFocus,
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (texto){ // se foi digitado o título muda
                  _formularioEditado = true;
                  setState(() {
                    _contatoEditado.nome=texto;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-Mail"),
                onChanged: (texto){
                  _formularioEditado = true;
                  _contatoEditado.email=texto;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _foneController,
                decoration: InputDecoration(labelText: "Fone"),
                onChanged: (texto){
                  _formularioEditado = true;
                  _contatoEditado.fone=texto;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _verificaConfirmacao(){
    if (_formularioEditado) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações ?"),
              content: Text("Se sair, as alterações serão perdidas !"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"), // Fecha o Alert
                  onPressed: () { Navigator.pop(context); },
                ),
                FlatButton(
                  child: Text("Sim"), // fecha o Alert e a Tela (2)
                  onPressed: (){ Navigator.pop(context);Navigator.pop(context); },
                ),
              ],
            );
          }
          );
      return Future.value(false); // nao vou deixar sair automaticamente da tela
    } else {
      return Future.value(true);  // deixa sair automaticamente
    }
  }
}
