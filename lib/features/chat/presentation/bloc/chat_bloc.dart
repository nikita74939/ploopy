import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

export 'chat_event.dart';
export 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  StreamSubscription? _roomsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<WatchChatRoomsEvent>(_onWatchChatRooms);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<WatchMessagesEvent>(_onWatchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesReadEvent>(_onMarkMessagesRead);
    on<ChatRoomsUpdatedEvent>(_onChatRoomsUpdated);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  Future<void> _onLoadChatRooms(
      LoadChatRoomsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final rooms = await repository.getChatRooms(event.userId);
      emit(ChatRoomsLoaded(rooms));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onWatchChatRooms(
      WatchChatRoomsEvent event, Emitter<ChatState> emit) async {
    await _roomsSubscription?.cancel();
    emit(ChatLoading());
    try {
      // Ambil data awal
      final rooms = await repository.getChatRooms(event.userId);
      emit(ChatRoomsLoaded(rooms));
      // Subscribe ke realtime stream
      _roomsSubscription =
          repository.watchChatRooms(event.userId).listen((rooms) {
        add(ChatRoomsUpdatedEvent(rooms));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages =
          await repository.getMessages(event.user1Id, event.user2Id);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onWatchMessages(
      WatchMessagesEvent event, Emitter<ChatState> emit) async {
    await _messagesSubscription?.cancel();
    emit(ChatLoading());
    try {
      final messages =
          await repository.getMessages(event.user1Id, event.user2Id);
      emit(MessagesLoaded(messages));
      _messagesSubscription =
          repository.watchMessages(event.user1Id, event.user2Id).listen(
              (messages) {
        add(MessagesUpdatedEvent(messages));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    // Optimistic: langsung update UI dengan isSending = true
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(MessagesLoaded(currentState.messages, isSending: true));
    }
    try {
      await repository.sendMessage(
        senderId: event.senderId,
        receiverId: event.receiverId,
        content: event.content,
      );
      // Stream akan otomatis update via WatchMessagesEvent
      // Jika tidak menggunakan stream, reload manual:
      if (_messagesSubscription == null) {
        final messages =
            await repository.getMessages(event.senderId, event.receiverId);
        emit(MessagesLoaded(messages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkMessagesRead(
      MarkMessagesReadEvent event, Emitter<ChatState> emit) async {
    try {
      await repository.markMessagesAsRead(event.senderId, event.receiverId);
    } catch (_) {}
  }

  void _onChatRoomsUpdated(
      ChatRoomsUpdatedEvent event, Emitter<ChatState> emit) {
    emit(ChatRoomsLoaded(event.rooms));
  }

  void _onMessagesUpdated(
      MessagesUpdatedEvent event, Emitter<ChatState> emit) {
    emit(MessagesLoaded(event.messages));
  }

  @override
  Future<void> close() async {
    await _roomsSubscription?.cancel();
    await _messagesSubscription?.cancel();
    return super.close();
  }
}