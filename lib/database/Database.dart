import 'dart:io';
import 'package:flutter_app_database/ClientModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider{
  DBProvider._();
  static final DBProvider db=DBProvider._();

  static Database _database;

  Future<Database> get database async{
    if(_database!=null){
      return _database;
    }

    _database= await initDB();
    return _database;
  }

  initDB() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, "main.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Client ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          "blocked BIT"
          ")");
    });



  }
  newClient(Client newClient) async {
    final db = await database;
    /*var res = await db.rawInsert(
        "INSERT Into Client (id,first_name)"
            " VALUES (${newClient.id},${newClient.firstName})");*/
    int res = await db.insert("Client", newClient.toJson());
    return res;
  }

  getClient(int id) async {
    final db = await database;
    var res =await  db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromJson(res.first) : Null ;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    List<Map> list = await db.rawQuery("SELECT * FROM Client");

//    list.isNotEmpty ? list.map((c) => Client.fromJson(c)).toList() : [];
    List<Client> clientList = new List();
    for (int i = 0; i < list.length; i++) {
      clientList.add(Client(
          id: list[i]["id"],
          firstName: list[i]["first_name"],
          lastName: list[i]['last_name'],
          blocked: (list[i]["blocked"] ==1)?true :false));
    }
    print(list.toString());
    print(list.length);
    return clientList;
  }

  getBlockedClients() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    List<Client> list =
    res.isNotEmpty ? res.toList().map((c) => Client.fromJson(c)) : null;
    return list;
  }

  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Client", newClient.toJson(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  blockOrUnblock(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update("Client", blocked.toJson(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  deleteClient(int id) async {
    final db = await database;
    db.delete("Client", where: "id = ?", whereArgs: [id]);
  }


  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Client");
  }



}