abstract class ILocalDataSource<T> {
  Future<T> get(int id);
  Future<void> set(int id, T data);
  Future<bool> unset(int id);
}
