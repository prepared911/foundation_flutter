import 'foundation.dart';

class HistoryManager<V> {
  final List<HistoryState<V>> _entries;
  final List<HistoryListener<V>> _listeners = [];

  HistoryManager(HistoryState<V> initialState):
        _entries = [initialState];

  bool get isTop => _entries.length == 1;

  HistoryState<V> get current => _entries.last;
  HistoryState<V>? get previous {
    if (_entries.length > 1) {
      return _entries[_entries.length - 2];
    } else {
      return null;
    }
  }

  Future<void> push(HistoryState<V> state) {
    final HistoryState<V> previous = current;
    _entries.add(state);
    _invokeListeners(HistoryAction.push, previous, state);
    return Future.value(null);
  }

  Future<void> replace(HistoryState<V> state) {
    final HistoryState<V> previous = current;
    _entries.removeLast();
    _entries.add(state);
    _invokeListeners(HistoryAction.replace, previous, state);
    return Future.value(null);
  }

  Future<bool> back() {
    if (isTop) {
      return Future.value(false);
    }
    final HistoryState<V> previous = _entries.removeLast();
    _invokeListeners(HistoryAction.back, previous, current);
    return Future.value(true);
  }

  void listen(HistoryListener<V> listener) {
    _listeners.add(listener);
  }

  void remove(HistoryListener<V> listener) {
    _listeners.remove(listener);
  }

  void _invokeListeners(HistoryAction action, HistoryState<V> previous, HistoryState<V> current) {
    _listeners.forEach((listener) => listener.apply(action, previous, current));
  }
}