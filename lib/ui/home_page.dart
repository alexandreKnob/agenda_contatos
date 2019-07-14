import 'dart:io';
import 'package:agenda_contatos/helpers/contato_helper.dart';
import 'package:flutter/material.dart';
import 'contato_editar.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {ordemaz,ordemza} // conjuto de constantes

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper helper = ContatoHelper();

  List<Contato> contatos = List();

  @override
  void initState() {
    super.initState();

/*
    Contato c = Contato();
    c.nome = "Alexandre Knob";
    c.email = "alexandre@abase.com.br";
    c.fone = "994134999";
    c.img = "";
    helper.salvaContato(c);
*/
    _buscaTodosContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos Alexandre Knob"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.ordemaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.ordemza,
              ),
            ],
            onSelected: _ordenarLista,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _abreContato();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          return _contatoCard(context, index);
        },
      ),
    );
  }


  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: contatos[index].img != null ?

                        /// verifica se estiver nul coloca pessoa.jpg
                        FileImage(File(contatos[index].img)) :
                        AssetImage("imagens/pessoa.jpg"),
                        fit: BoxFit.cover,

                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(contatos[index].nome ?? "",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(contatos[index].email ?? "",
                          style: TextStyle(fontSize: 18)),
                      Text(contatos[index].fone ?? "",
                          style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ],
            )),
      ),
      onTap: () { // gesture detector
        //_abreContato(contato: contatos[index]);
        _mostraOpcoes(context, index);
      },
    );
  }

  void _mostraOpcoes(BuildContext context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet( // tela no rodape com opções
              onClosing: () {}, // requerido
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // deixa menor
                    children: <Widget>[
                      Padding( padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                            launch("tel:${contatos[index].fone}"); // abre o telefone
                          },
                          child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                        ),),
                      Padding(padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context); // fecha a janela.
                            _abreContato(contato: contatos[index]); // abre a edição
                            },
                          child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                        ),),
                      Padding(padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          onPressed: () {
                              Navigator.pop(context); // fecha a janela.
                              helper.deletaContato(contatos[index].id); // deleta do banco
                              setState(() {
                                contatos.removeAt(index); // deleta da lista
                              });
                            },
                          child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                        ),),
                    ],
                  ),
                );
              }
          );
        }
    );
  }


  /* void _abreContato({Contato contato}){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContatoEditar(contato: contato))
    );

  }
*/
  void _abreContato({Contato contato}) async {
    // abro a página e recebo um retorno em contatoRecebido
    final contatoRecebido = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContatoEditar(contato: contato))
    );
    if (contatoRecebido != null) { // se o que voltou tem contato
      if (contato != null) { // se enviei um contato/ ai atualiza.
        await helper.atualizaContato(contatoRecebido);
      } else {
        await helper.salvaContato(contatoRecebido); // caso contrário é um novo
      }
      _buscaTodosContatos();
    }
  }

  void _buscaTodosContatos() {
    helper.getAllContatos().then((lista) {
      setState(() {
        contatos = lista;
        //print(lista);
      });
    });
  }

  void _ordenarLista(OrderOptions resultado){
    switch (resultado) {
      case OrderOptions.ordemaz:
        contatos.sort((a,b){
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.ordemza:
        contatos.sort((a,b){
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {
    });
  }

}
