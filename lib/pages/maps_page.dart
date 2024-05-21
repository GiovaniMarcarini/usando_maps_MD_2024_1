
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget{

  const HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  Position? _localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao => _localizacaoAtual == null ? "" :
      'Latitude: ${_localizacaoAtual!.latitude}  | Longitude: '
                '${_localizacaoAtual!.longitude}';

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usando Mapas'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => ListView(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          child: Text('Obter Localização Atual'),
          onPressed: _obterLocalizacaoAtual,
        ),
      ),
    ],
  );


  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }

    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas){
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

  }

  Future<bool> _permissoesPermitidas() async{
    LocationPermission permissao = await Geolocator.checkPermission();

    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied){
        _mostrarMensagem(
            'Não será possível usar o recurso por falta de permissão'
        );
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever){
      await _mostrarDialogMensagem(
          'Para utilizar esse recurso, você deverá acessar as configurações'
              ' do app e permitir a utilização do serviço de localização'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<bool> _servicoHabilitado() async{
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();

    if (!servicoHabilitado){
      await _mostrarDialogMensagem('Para utilizar esse serviço, você deverá '
          'habilitar o serviço de localização do dispositivo.');

      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem),
    ));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK')
            )
          ],
        )
    );
  }

}