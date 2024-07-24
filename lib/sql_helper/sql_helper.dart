import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/province.dart';

class SqlHelper {
  static const _databaseName = "Province.db";
  static const _databaseVersion = 1;
  static const _provincesTable = 'province';

  static const _columnId = 'id';
  static const _columnProvinceName = 'ProvinceName';
  static const _columnCity = 'City';
  static const _columnLicensePlate = 'licensePlate';
  static const _columnCreatedAt = 'createdAt';

  static Future<void> createProvinceTable(Database database) async {
    try {
      await database.execute('''
 CREATE TABLE $_provincesTable (
 $_columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
 $_columnProvinceName TEXT ,
 $_columnCity TEXT ,
 $_columnLicensePlate INTEGER ,
$_columnCreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 )''');
    } catch (err) {
      debugPrint("createProvinceTable(): $err");
    }
  }

  static Future<Database> getDb() async {
    return openDatabase(_databaseName, version: _databaseVersion,
        onCreate: (Database database, int version) async {
      await createProvinceTable(database);
    });
  }

  static Future<int> createProvince(Province province) async {
    int id = 0;

    try {
      final db = await SqlHelper.getDb();

      id = await db.insert(_provincesTable, province.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      debugPrint("createProvince():$err");
    }
    return id;
  }

  static Future<List<Map<String, dynamic>>> getProvinces() async {
    late Future<List<Map<String, dynamic>>> provinces;

    try {
      final db = await SqlHelper.getDb();
      provinces = db.query(_provincesTable, orderBy: _columnId);
    } catch (err) {
      debugPrint("getProvinces():$err");
    }

    return provinces;
  }

  static Future<List<Map<String, dynamic>>> getOrderedProvinces() async {
    late Future<List<Map<String, dynamic>>> provinces;

    try {
      final db = await SqlHelper.getDb();
      provinces = db.query(_provincesTable, orderBy: _columnProvinceName);
    } catch (err) {
      debugPrint("getProvinces():$err");
    }

    return provinces;
  }

  static Future<List<Map<String, dynamic>>> getOrderedDESCProvinces() async {
    late Future<List<Map<String, dynamic>>> provinces;

    try {
      final db = await SqlHelper.getDb();
      provinces =
          db.query(_provincesTable, orderBy: '$_columnProvinceName DESC');
    } catch (err) {
      debugPrint("getProvinces():$err");
    }

    return provinces;
  }

  static Future<List<Map<String, dynamic>>> getProvince(String title) async {
    late Future<List<Map<String, dynamic>>> province;

    try {
      final db = await SqlHelper.getDb();

      province = db.query(_provincesTable,
          where: "$_columnProvinceName=?", whereArgs: [title], limit: 1);
    } catch (err) {
      debugPrint("getProvince():$err");
    }
    return province;
  }

  static Future<int> updateProvince(Province province) async {
    int result = 0;

    try {
      final db = await SqlHelper.getDb();
      result = await db.update(_provincesTable, province.toMap(),
          where: "$_columnId=?", whereArgs: [province.id]);
    } catch (err) {
      debugPrint("updateProvince():$err");
    }
    return result;
  }

  static Future<void> deleteProvince(int id) async {
    try {
      final db = await SqlHelper.getDb();
      await db.delete(_provincesTable, where: "$_columnId=?", whereArgs: [id]);
    } catch (err) {
      debugPrint("deleteProvince():$err");
    }
  }
}
