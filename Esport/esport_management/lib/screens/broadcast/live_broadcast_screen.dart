import 'package:camera/camera.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveBroadcastScreen extends StatefulWidget {
  final String tournamentId;

  const LiveBroadcastScreen({super.key, required this.tournamentId});

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen> {
  CameraController? _controller;
  bool _isStreaming = false;
  bool _isLoading = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = _cameras!.first;
        _controller = CameraController(camera, ResolutionPreset.high, enableAudio: true);
        await _controller!.initialize();
      } else {
        _showError('No cameras available.');
      }
    } on CameraException catch (e) {
      _showError('Failed to initialize camera: ${e.description}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_isStreaming) {
      _stopStreaming();
    }
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleStreaming() async {
    if (_isLoading || _controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    if (_isStreaming) {
      await _stopStreaming();
    } else {
      await _startStreaming();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _startStreaming() async {
    try {
      // !!! IMPORTANT: EDIT THESE VALUES !!!
      // Replace these with the address and port from your serveo.net terminal.
      const publicAddress = '<YOUR_SERVEO_ADDRESS>'; // e.g., 'some-name.serveo.net'
      const publicPort = 12345; // e.g., 43210 (use the number, not a string)

      final streamKey = widget.tournamentId;

      // This is the RTMP URL your app will stream TO.
      final rtmpUrl = 'rtmp://$publicAddress:$publicPort/live/$streamKey';

      // This is the HLS URL your viewers will stream FROM.
      // NOTE: serveo.net cannot forward two ports at once on the free plan.
      // For a full test, you would need a proper server or a paid plan.
      // We will use a placeholder here for now.
      final hlsUrl = 'http://$publicAddress:$publicPort/live/$streamKey/index.m3u8';

      print("Attempting to stream to: $rtmpUrl");

      // TODO: Connect the camera controller to your media server.
      // The Flutter camera plugin's API for live streaming is in development.
      // When available, the command will look something like this:
      // await _controller.startVideoStreaming(rtmpUrl);

      await context.read<TournamentService>().setTournamentLive(widget.tournamentId, hlsUrl);

      setState(() {
        _isStreaming = true;
      });
    } catch (e) {
      _showError('Failed to start stream: $e');
    }
  }

  Future<void> _stopStreaming() async {
    try {
      // Conceptual: await _controller.stopVideoStreaming();
      print("Stopping stream...");

      await context.read<TournamentService>().updateLiveStatus(widget.tournamentId, false);

      setState(() {
        _isStreaming = false;
      });
    } catch (e) {
      _showError('Failed to stop stream: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Broadcast'),
      ),
      body: _controller == null
          ? const Center(child: Text('Initializing Camera...'))
          : Column(
              children: [
                if (_controller!.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  )
                else
                  const Center(child: Text('Camera not available')),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _toggleStreaming,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStreaming ? Colors.red : Colors.green,
                    ),
                    child: Text(_isStreaming ? 'Stop Stream' : 'Start Stream'),
                  ),
              ],
            ),
    );
  }
}
