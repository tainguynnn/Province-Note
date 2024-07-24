import 'package:database/screen/search_result.dart';
import 'package:database/sql_helper/sql_helper.dart';
import 'package:flutter/material.dart';

import 'package:database/models/province.dart';

class ProvinceScreen extends StatelessWidget {
  const ProvinceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({super.key});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  List<Map<String, dynamic>> _provinces = [];

  bool _isLoading = true;
  int sortCounter = 0;

  Future<void> _refreshProvinces() async {
    final data = await SqlHelper.getProvinces();

    setState(() {
      _provinces = data;
      _isLoading = false;
    });
  }

  Future<void> _sortProvinces(int sortCounter) async {
    switch (sortCounter) {
      case 0:
        ScaffoldMessenger.of(context).clearSnackBars();
        _refreshProvinces();
        break;
      case 1:
        final data = await SqlHelper.getOrderedProvinces();
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ordered by A to Z alphabetically!'),
        ));
        setState(() {
          _provinces = data;
          _isLoading = false;
        });
      case 2:
        final data = await SqlHelper.getOrderedDESCProvinces();
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ordered by Z to A alphabetically!'),
        ));
        setState(() {
          _provinces = data;
          _isLoading = false;
        });
    }
  }

  Future<void> _sortDESCProvinces() async {
    final data = await SqlHelper.getOrderedDESCProvinces();

    setState(() {
      _provinces = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshProvinces();
  }

  final TextEditingController _provinceNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _findProvinceController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingProvince =
          _provinces.firstWhere((element) => element['id'] == id);
      _provinceNameController.text = existingProvince['ProvinceName'];
      _cityController.text = existingProvince['City'];
      _licensePlateController.text =
          existingProvince['licensePlate'].toString();
    } else {
      _provinceNameController.text = '';
      _cityController.text = '';
      _licensePlateController.text = '';
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _provinceNameController,
                    decoration:
                        const InputDecoration(hintText: 'Province Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _cityController,
                    decoration: const InputDecoration(hintText: 'City'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    controller: _licensePlateController,
                    decoration:
                        const InputDecoration(hintText: 'License Plate'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new item
                      if (id == null) {
                        await _addProvince();
                      } else {
                        await _updateProvince(id);
                      }
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  // Insert a new item to the database
  Future<void> _addProvince() async {
    if (_provinceNameController.text == '' ||
        _cityController.text == '' ||
        _licensePlateController.text == '') {
      _showAlertDialog();
    } else {
      await SqlHelper.createProvince(Province(
          provinceName: _provinceNameController.text,
          city: _cityController.text,
          licensePlate: _licensePlateController.text));
      if (!mounted) return;
      Navigator.of(context).pop();
      _refreshProvinces();
    }
  }

  // Update an existing item
  Future<void> _updateProvince(int id) async {
    if (_provinceNameController.text == '' ||
        _cityController.text == '' ||
        _licensePlateController.text == '') {
      _showAlertDialog();
    } else {
      await SqlHelper.updateProvince(Province(
          id: id,
          provinceName: _provinceNameController.text,
          city: _cityController.text,
          licensePlate: _licensePlateController.text));
      if (!mounted) return;
      Navigator.of(context).pop();
      _refreshProvinces();
    }
  }

  Future<void> _deleteProvince(int id) async {
    await SqlHelper.deleteProvince(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a item!'),
    ));

    _refreshProvinces();
  }

  Future<void> _getProvince(String title) async {
    if (title == '') {
      _refreshProvinces();
    } else {
      final data = await SqlHelper.getProvince(title);

      setState(() {
        _provinces = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your input information is invalid'),
                Text('Please check again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your input information is invalid'),
                Text('Please check again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                _deleteProvince(id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Province'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.find_in_page),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                elevation: 5,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 120,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Enter Province Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _findProvinceController,
                          decoration:
                              const InputDecoration(hintText: 'Province Name'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _getProvince(_findProvinceController.text);
                            _findProvinceController.text = '';
                            Navigator.of(context).pop();
                          },
                          child: const Text('Find'),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Sort',
            onPressed: () {
              if (sortCounter < 2) {
                sortCounter++;
              } else {
                sortCounter = 0;
              }
              _sortProvinces(sortCounter);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _provinces.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_provinces[index]['ProvinceName']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_provinces[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteDialog(_provinces[index]['id']),
                            // _deleteProvince(_provinces[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
