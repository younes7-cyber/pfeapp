import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class NoConnectionWidget extends StatefulWidget {
  final VoidCallback onRetry;

  const NoConnectionWidget({Key? key, required this.onRetry}) : super(key: key);

  @override
  State<NoConnectionWidget> createState() => _NoConnectionWidgetState();
}

class _NoConnectionWidgetState extends State<NoConnectionWidget> {
  late RecorderController recorderController;

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController();
    _startWaveSimulation();
  }

  void _startWaveSimulation() {
    Future.delayed(Duration.zero, () async {
      while (mounted) {
        recorderController.refresh();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              'Pas de connexion Internet',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: AudioWaveforms(
                enableGesture: true,
                size: Size(MediaQuery.of(context).size.width, 100.0),
                recorderController: recorderController,
                waveStyle: const WaveStyle(
                  waveColor: Colors.greenAccent,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
