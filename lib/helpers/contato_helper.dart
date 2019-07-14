import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

final String contatoTabela = "contatoTabela";
final String idColuna = "idColuna";
final String nomeColuna = "nomeColuna";
final String emailColuna = "emailColuna";
final String foneColuna = "foneColuna";
final String imgColuna = "imgColuna";

class ContatoHelper {

  // Classe do tipo Singleton, so tem um objeto, nao importa quantas vezes instancia
  static final ContatoHelper _instance = ContatoHelper.internal();
  factory ContatoHelper() => _instance;
  ContatoHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await iniciaDb();
      return _db;
    }
  }

  Future<Database> iniciaDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contatos.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $contatoTabela ("
          "$idColuna INTEGER PRIMARY KEY, "
          "$nomeColuna TEXT,"
          "$emailColuna TEXT,"
          "$foneColuna TEXT,"
          "$imgColuna TEXT)");
    });
  }

  Future<Contato> salvaContato(Contato contato) async {
    // obtém o banco de dados
    Database dbContato = await db;
    // faz o insert e retorna o ID do registro
    contato.id = await dbContato.insert(contatoTabela, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database dbContato = await db; // obter o banco de dados
    List<Map> mapa = await dbContato.query(contatoTabela,
        columns: [idColuna, nomeColuna, emailColuna, foneColuna, imgColuna],
        where: "$idColuna = ?",
        whereArgs: [id]);
    if (mapa.length > 0) {
      return Contato.fromMap(mapa.first);
    } else {
      return null;
    }
  }

  Future<int> deletaContato(int id) async {
    // retorna um numero inteiro sei deletado ou nao.
    Database dbContato = await db; // obtenho o banco de dados
    return await dbContato.delete(contatoTabela,
        where: "$idColuna = ?",
        whereArgs: [id]);
  }

  Future<int> atualizaContato(Contato contato) async {
    Database dbContato = await db; // obtenho o banco de dados
    return await dbContato.update(contatoTabela,
        contato.toMap(),
        where: "$idColuna = ?" ,
        whereArgs: [contato.id]);
  }

  Future<List> getAllContatos() async {
    Database dbContato = await db; // obtenho o banco de dado

    // Crio uma lista de Mapas e jogo o resultado da minha SQL
    List listaMapa = await dbContato.rawQuery("SELECT * FROM $contatoTabela");
    // Crio uma lista de contatos
    List<Contato> listaContato = List();
    // percorro a listaMapa que retornou do meu SQL e adiciono no listaContato
    // que é to tipo Contato
    for(Map m in listaMapa){
      listaContato.add(Contato.fromMap(m));
    }
    return listaContato;
  }

  Future<int> getNumber() async {
    Database dbContato = await db; // obtenho o banco de dado
    return Sqflite.firstIntValue(
        await dbContato.rawQuery("SELECT COUNT(*) FROM $contatoTabela"));
  }

  Future close() async {
    Database dbContato = await db; // obtenho o banco de dado
    dbContato.close();
  }
}

class Contato {
  int id;
  String nome;
  String email;
  String fone;
  String img;

  Contato(); // Construtor vazio para a instancia

  // o Construtor irá transformar do mapa para o contato, colunas
  Contato.fromMap(Map mapa) {
    id = mapa[idColuna];
    nome = mapa[nomeColuna];
    email = mapa[emailColuna];
    fone = mapa[foneColuna];
    img = mapa[imgColuna];
  }

  // função que retorna dos campos para o mapa
  // so retorna o ID se tem o valor, na inclusao nao tem.
  Map toMap() {
    Map<String, dynamic> mapa = {
      nomeColuna: nome,
      emailColuna: email,
      foneColuna: fone,
      imgColuna: img
    };
    if (id != null) {
      mapa[idColuna] = id;
    }
    return mapa;
  }

  // reescrevemos o método toString para facilitar quando queremos dar um print no contato
  @override
  String toString() {
    return "Contato(id: $id, nome: $nome, email:$email, img: $img)";
  }

}
