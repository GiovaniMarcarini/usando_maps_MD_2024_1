
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';

class HomePage extends StatefulWidget{

  const HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  Position? _localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao => _localizacaoAtual == null ? '' :
  'Latitude: ${_localizacaoAtual!.latitude}  |  Longitude: ${_localizacaoAtual!.longitude}';

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Usando Mapas'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => ListView(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          child: Text('Obter Localização Atual'),
          onPressed: _obterLocalizacaoAtual,
        ),
      ),

      if(_localizacaoAtual != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(_textoLocalizacao),
              ),
              ElevatedButton(
                  onPressed: _abrirCoordenadasNoMaPaExterno,
                  child: const Icon(Icons.map)
              ),
            ],
          ),
        ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: _controller,
          decoration:  InputDecoration(
            labelText: 'Endereço ou ponto de referência',
            suffixIcon: IconButton(
                onPressed: _abrirNoMapaExterno,
                icon: const Icon(Icons.map),
              tooltip: 'Abrir no Mapa',
            ),
          ),
        ),
      ),
    ],
  );

  void _abrirNoMapaExterno(){
    if(_controller.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  void _abrirCoordenadasNoMaPaExterno(){
    if(_localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(
        _localizacaoAtual!.latitude,
        _localizacaoAtual!.longitude,
    );
  }

  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }

    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas){
      return;
    }

    _localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {

    });

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