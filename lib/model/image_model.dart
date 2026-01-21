import 'dart:io' as html;

class ImageModel {
  String id;
  final String? fullPath;
  final String url;
  final String bucket;
  final String folder;
  final String filename;
  final int? sizeBytes;
  final String? contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final html.File? file;
  ImageModel({
    this.id = '',
    this.fullPath,
    required this.url,
    this.bucket = '',
    required this.folder,
    required this.filename,
    this.sizeBytes,
    this.contentType,
    this.createdAt,
    this.updatedAt,
    this.file,
  });

  static ImageModel empty() =>
      ImageModel(url: '', folder: '', filename: '', bucket: '');

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'folder': folder,
      'sizeBytes': sizeBytes,
      'filename': filename,
      'fullPath': fullPath,
      'createdAt': createdAt?.toUtc(),
      'contentType': contentType,
    };
  }
}
