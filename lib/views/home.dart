import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final decimalController = TextEditingController();
  final binarioController = TextEditingController();
  final hexaController = TextEditingController();

  void fake(var decimalController) {}

  void _clearAll() {
    decimalController.text = "";
    binarioController.text = "";
    hexaController.text = "";
  }

  void calcular(var decimalController) {
    var sinal = '0'; //1 digito
    var expoente32 = '00000000';
    var mantissa32 = '00000000000000000000000';

    if (decimalController.isEmpty) {
      binarioController.text = "";
      hexaController.text = "";
    }

    if (double.parse(decimalController) > 256) {
      print('NECESSÁRIO UTILIZAR A VERSÃO 64 BITS');
    }

    if (double.parse(decimalController).isNegative) {
      print('é negativo');
      sinal = "1";
    } else {
      sinal = "0";
    }

//DIVIDE O NUMERO PELO PONTO
    var separavalor = decimalController.split('.');

    double valor = double.parse(
        decimalController.replaceAll('-', '').replaceAll(',', '.'));

    int parteinteira = valor.truncate();
    double partefracao = 0;
    if (separavalor.length > 1) {
      partefracao = double.parse('0.' + separavalor[1]);
    }

//CALCULO DO INTEIRO
    int value = parteinteira;
    var lista = [];
    if (value == 0) {
      lista.add('0');
    }
    if (value != 0) {
      while (value > 0) {
        if (value >= 2) {
          lista.add((value % 2).toString());
          value = (value ~/ 2);
        } else if (value == 1) {
          lista.add('1');
          value = 0;
        }
      }
    }

    var binary = lista.reversed.toList();
    String binariointeiro = '';

    if (lista.length > 1) {
      binariointeiro = binary.join();
    } else {
      binariointeiro = lista[0].toString();
    }

//CALCULO DO FRACIONADO
    var expo = 0;
    var listafraci1 = [];
    var fracaocalc1 = partefracao;
    int i = 0;

    while (i < 8) {
      fracaocalc1 = (fracaocalc1 * 2);
      if (fracaocalc1 >= 1) {
        fracaocalc1 -= 1;
        listafraci1.add(1);
      } else {
        listafraci1.add(0);
      }
      i++;
    }

//JUNÇÃO DAS DUAS PARTES
    double juntabinario =
        double.parse(binariointeiro + '.' + listafraci1.join());

//NORMALIZAÇÃO DOS BINÁRIOS
    if (juntabinario != 0) {
      while (juntabinario >= 10 || juntabinario < 1) {
        if (juntabinario >= 10) {
          juntabinario /= 10;
          expo++;
        }
        if (juntabinario < 1) {
          juntabinario *= 10;
          expo--;
        }
      }
    }

//CALCULO DA MANTISSA E SEU BINÁRIO
    var listabias = [];
    var bias32 = 127 + expo;
    if (bias32 != 0) {
      while (bias32 > 0) {
        if (bias32 >= 2) {
          listabias.add((bias32 % 2).toString());
          bias32 = (bias32 ~/ 2);
        } else if (bias32 == 1) {
          listabias.add('1');
          bias32 = 0;
        }
      }
      if (listabias.length < 8) {
        listabias.add('0');
      }
    }
    expoente32 = listabias.reversed.toList().join();

    var listafraci2 = [];
    var fracaocalc2 = partefracao;
    int x = expo;
    while (x < 23) {
      fracaocalc2 = (fracaocalc2 * 2);
      if (fracaocalc2 >= 1) {
        fracaocalc2 -= 1;
        listafraci2.add(1);
      } else {
        listafraci2.add(0);
      }
      x++;
    }
    var juncao2 = binariointeiro + listafraci2.join();

//FATIANDO A LISTA FINAL
    var finallist = juncao2.split('');

    if (expo.isNegative) {
      finallist.removeRange(0, (expo - 1) * (-1));

      mantissa32 = finallist.join();
    } else if (!expo.isNegative) {
      finallist.removeRange(0, 1);
      mantissa32 = finallist.join();
    }

    String finalconvert = sinal + expoente32 + mantissa32;

    var listabintohexa = finalconvert.split('').map(int.parse).toList();
    var hexalist = [];

    var y = 0;
    var pos = 0;
    while (y < 8) {
      int hexa1 = (listabintohexa[pos] * 8) +
          (listabintohexa[pos + 1] * 4) +
          (listabintohexa[pos + 2] * 2) +
          (listabintohexa[pos + 3] * 1);
      hexalist.add(hexa1
          .toString()
          .replaceAll('10', 'a')
          .replaceAll('11', 'b')
          .replaceAll('12', 'c')
          .replaceAll('13', 'd')
          .replaceAll('14', 'e')
          .replaceAll('15', 'f'));
      pos += 4;
      y += 1;
    }

    String listafinal = hexalist.join();
    print('o binario final é $finalconvert');
    print('o hexa final é $listafinal');

    binarioController.text = finalconvert;
    hexaController.text = '0x' + listafinal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ILP500 IEEE 754 32 Bits'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clearAll,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.code_outlined,
              size: 150,
            ),
            ElevatedButton.icon(
              onPressed: () => calcular(decimalController),
              icon: Icon(Icons.code_sharp),
              label: Text(
                'Converter!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Divider(
              height: 40,
            ),
            buildTextField("Valor Decimal", decimalController, calcular),
            Divider(),
            buildTextField("Valor Binário", binarioController, fake),
            Divider(),
            buildTextField("Valor Final em Hexadecimal", hexaController, fake),
          ],
        ),
      ),
    );
  }
}

Widget buildTextField(String label, TextEditingController value, Function f) {
  return TextField(
    onChanged: f,
    controller: value,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 25),
      border: OutlineInputBorder(),
    ),
    style: TextStyle(fontSize: 18),
    //onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    // O comando acima também permite os decimais dentro do IOS
  );
}
