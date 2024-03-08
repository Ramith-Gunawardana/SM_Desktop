import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// Future<List<Document>> getData() async {
//   final List<Document> data =
//       await Firestore.instance.collection('Data').orderBy('datetime').get();
//   print(data);
//   return data;
// }

class _HomeState extends State<Home> {
  // CollectionReference dataCollection = Firestore.instance.collection('Data');
  late Stream<List<Document>> _dataStream;

  Future<void> refresh() async {
    setState(() {
      _dataStream = Firestore.instance
          .collection('Data')
          .orderBy('datetime')
          .get()
          .asStream();
    });
  }

  @override
  void initState() {
    _dataStream = Firestore.instance
        .collection('Data')
        .orderBy('datetime')
        .get()
        .asStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: FilledButton.icon(
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              StreamBuilder(
                stream: _dataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: GlowingOverscrollIndicator(
                        showLeading: false,
                        axisDirection: AxisDirection.down,
                        color: Theme.of(context).primaryColor,
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: snapshot.data!.isNotEmpty
                              ? ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: snapshot.data!
                                      .map((data) {
                                        return ListTile(
                                          title: Text(
                                            data['data'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(data['datetime']),
                                        );
                                      })
                                      .toList()
                                      .reversed
                                      .toList(),
                                )
                              : const Text('No data'),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error loading data');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
