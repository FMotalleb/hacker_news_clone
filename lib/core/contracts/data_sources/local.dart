abstract class ILocalDataSource<T> {
  Future<T> get(int id);
  Future<int> set(int id, T data);
  Future<bool> unset(int id);
}
