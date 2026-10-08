// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final soundDir = Directory('assets/sounds');
  if (!soundDir.existsSync()) {
    soundDir.createSync(recursive: true);
  }

  // 1. Task Added sound: sweet two-note chime
  final addedBytes = generateChime(
    frequencies: [659.25, 880.0], // E5 -> A5
    durations: [0.09, 0.22],
    sampleRate: 44100,
  );
  File('assets/sounds/task_added.wav').writeAsBytesSync(addedBytes);

  // 2. Task Completed sound: celebratory fanfare arpeggio ("Hurray!" / triumph chime)
  final completedBytes = generateFanfare(
    sampleRate: 44100,
  );
  File('assets/sounds/task_completed.wav').writeAsBytesSync(completedBytes);

  print('Sound files generated successfully!');
}

Uint8List generateChime({
  required List<double> frequencies,
  required List<double> durations,
  required int sampleRate,
}) {
  final totalDuration = durations.reduce((a, b) => a + b);
  final totalSamples = (totalDuration * sampleRate).toInt();
  final samples = Float64List(totalSamples);

  int sampleOffset = 0;
  for (int note = 0; note < frequencies.length; note++) {
    final freq = frequencies[note];
    final noteDuration = durations[note];
    final noteSamples = (noteDuration * sampleRate).toInt();

    for (int i = 0; i < noteSamples && (sampleOffset + i) < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / noteSamples;
      // Exponential decay
      final envelope = exp(-3.5 * progress);
      // Main tone + subtle harmonic overtone
      final val = (sin(2 * pi * freq * t) * 0.75 +
                   sin(2 * pi * freq * 2 * t) * 0.25) * envelope;
      samples[sampleOffset + i] = val;
    }
    sampleOffset += noteSamples;
  }

  return encodeWav(samples, sampleRate);
}

Uint8List generateFanfare({required int sampleRate}) {
  // Arpeggio: C5 -> E5 -> G5 -> C6 with high sparkle
  final notes = [
    (523.25, 0.08),  // C5
    (659.25, 0.08),  // E5
    (783.99, 0.08),  // G5
    (1046.50, 0.38), // C6 (sustained celebration)
  ];

  final totalDuration = 0.08 * 3 + 0.38;
  final totalSamples = (totalDuration * sampleRate).toInt();
  final samples = Float64List(totalSamples);

  int sampleOffset = 0;
  for (int n = 0; n < notes.length; n++) {
    final freq = notes[n].$1;
    final noteDur = notes[n].$2;
    final noteSamples = (noteDur * sampleRate).toInt();
    final isLast = n == notes.length - 1;

    for (int i = 0; i < noteSamples && (sampleOffset + i) < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / noteSamples;
      final envelope = isLast ? exp(-2.2 * progress) : exp(-1.5 * progress);

      // Harmony on final chord
      double val = sin(2 * pi * freq * t) * 0.6 +
                   sin(2 * pi * freq * 2 * t) * 0.2;
      if (isLast) {
        // Add major third overtone (E6) for rich victory bell
        val += sin(2 * pi * 1318.51 * t) * 0.25;
      }
      samples[sampleOffset + i] += val * envelope;
    }
    sampleOffset += (noteDur * sampleRate).toInt();
  }

  return encodeWav(samples, sampleRate);
}

Uint8List encodeWav(Float64List samples, int sampleRate) {
  final numSamples = samples.length;
  final byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
  final dataChunkSize = numSamples * 2;
  final fileSize = 36 + dataChunkSize;

  final buffer = ByteData(44 + dataChunkSize);

  // RIFF header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, fileSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt chunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // chunk size = 16 for PCM
  buffer.setUint16(20, 1, Endian.little);  // audio format = 1 (PCM)
  buffer.setUint16(22, 1, Endian.little);  // num channels = 1 (mono)
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, 2, Endian.little);  // block align = 2
  buffer.setUint16(34, 16, Endian.little); // bits per sample = 16

  // data chunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataChunkSize, Endian.little);

  for (int i = 0; i < numSamples; i++) {
    final s = samples[i].clamp(-1.0, 1.0);
    final pcm = (s * 32767).toInt();
    buffer.setInt16(44 + i * 2, pcm, Endian.little);
  }

  return buffer.buffer.asUint8List();
}
