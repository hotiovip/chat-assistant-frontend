import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
// import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/api/auth_http_service.dart';
import 'package:flutter_application/chat/chat_service.dart';
import 'package:flutter_application/chat/chat_message.dart';
import 'package:flutter_application/chat/role.dart';
import 'package:flutter_application/utils.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  final String title = "Chats";

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  List<String> _threadIds = [];
  String _currentThreadId = "";

  @override
  void initState() {
    super.initState();
    _loadChatAndSetState();
  }

  Future<void> _loadChatAndSetState() async {
    final List<String>? threadIds = await _chatService.getThreads();
    if (threadIds != null) {
      _threadIds = threadIds;
    }
    else {
      log("Thread ID is null. Creating new thread");
      final String? threadId = await _chatService.createThread();
      if (threadId != null) {
        _threadIds.add(threadId);
      }
      else {
        log("ERROR: Got null from createThread()");
      }
    }
    // final loadedMessages = await _loadChat();
    setState(() {
      // _messages = loadedMessages;
      if (_threadIds != null && _threadIds.isNotEmpty) _currentThreadId = _threadIds.first;
    });
  }
  Future<List<String>> _loadChat(String threadId) async {
    
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ChatMessage chatMessage = ChatMessage(role: Role.user, content: text);
    setState(() {
      _messages.add(chatMessage);
    });

    _controller.clear();

    // Get threadId from backend
    String threadId = await _chatService.send(_currentThreadId, chatMessage);

    // Add response as message
    // setState(() {
    //   _messages.add(ChatMessage(role: Role.assistant, content: response));
    // });
  }
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? filePickerResult = await pickFile();
    if (filePickerResult != null) {
      // File is not null. Upload it to our backend
      PlatformFile platformFile = filePickerResult.files.first;
      Uint8List? bytes = platformFile.bytes;

      if (bytes != null && bytes.isNotEmpty) {
        _chatService.file(bytes);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Theme.of(context).colorScheme.primary,),
      body: Row(
        children: [
          // Left Sidebar List
          Container(
            width: 250,
            child: ListView.builder(
              itemCount: _threadIds.length, // Replace with your thread list
              itemBuilder: (context, index) {
                final thread = _threadIds[index]; // Replace with your model
                return ListTile(
                  title: Text('Thread ${index + 1}'), // Customize display
                  onTap: () => _selectThread(thread),
                );
              },
            ),
          ),

          // Divider between sidebar and chat
          VerticalDivider(width: 1),

          // Main Chat Area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (_, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return Align(
                        alignment: message.role == Role.user
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.role == Role.user
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: _pickAndUploadFile,
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}