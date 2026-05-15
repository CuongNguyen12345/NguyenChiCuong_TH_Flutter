import '../models/playlist_model.dart';
import 'storage_service.dart';

class PlaylistService {
  final StorageService _storageService;

  PlaylistService(this._storageService);

  Future<List<PlaylistModel>> loadPlaylists() {
    return _storageService.getPlaylists();
  }

  Future<void> savePlaylists(List<PlaylistModel> playlists) {
    return _storageService.savePlaylists(playlists);
  }
}
