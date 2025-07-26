import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/chat/thread_service.dart';
import 'package:flutter_application/chat/chat_message.dart';
import 'package:flutter_application/chat/role.dart';
import 'package:flutter_application/chat/run_status.dart';
import 'package:flutter_application/chat/smooth_typing_indicator.dart';
import 'package:flutter_application/utils.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});
  final String title = "Chats";

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final _controller = TextEditingController();
  final ThreadService _chatService = ThreadService();
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
      setState(() {
        _threadIds = threadIds;
      });

      _selectThread(_threadIds.first);
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
  }
  Future<void> _selectThread(String threadId) async {
    if (_currentThreadId == threadId) return;

    _currentThreadId = threadId;
    final List<ChatMessage>? loadedMessages = await _chatService.getMessages(_currentThreadId);
    if (loadedMessages != null) {
      setState(() {
        _messages = loadedMessages;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(role: Role.user, contentList: [text]);
    setState(() {
      _messages.add(userMessage);
    });

    _controller.clear();

    // Send message and get runId
    String runId = await _chatService.send(_currentThreadId, userMessage);
    log('Run ID: $runId');

    // Add loading placeholder
    setState(() {
      _messages.add(ChatMessage(role: Role.assistant, contentList: ['typing']));
    });

    // Poll until run is complete
    RunStatus? status;
    do {
      await Future.delayed(Duration(seconds: 2));
      status = await _chatService.getRunStatus(_currentThreadId, runId);
    } while (status != RunStatus.completed);

    // Fetch latest messages after completion
    final updatedMessages = await _chatService.getMessages(_currentThreadId);

    // Replace the placeholder with the actual assistant message
    if (updatedMessages != null) {
      // Find the latest assistant message (last in list)
      final newAssistantMessage = updatedMessages.lastWhere(
        (m) => m.role == Role.assistant,
        orElse: () => ChatMessage(role: Role.assistant, contentList: ['(no response)']),
      );

      setState(() {
        _messages.removeLast(); // remove the "•••"
        _messages.add(newAssistantMessage);
      });
    }
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
          SizedBox(
            width: 250,
            child: ListView.builder(
              itemCount: _threadIds.length, // Replace with your thread list
              itemBuilder: (context, index) {
                final threadId = _threadIds[index]; // Replace with your model
                return ListTile(
                  title: Text('Thread $threadId'), // Customize display
                  onTap: () => _selectThread(threadId),
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

                      if (message.role == Role.assistant &&
                          message.contentList.length == 1 &&
                          message.contentList.first == "typing") {
                        // Assistant bubble with typing indicator inside
                        return Align(
                          alignment: Alignment.centerLeft,  // assistant messages align left
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: 20,  // adjust this to fit your font size nicely
                              child: SmoothTypingIndicator(),
                            ), // your animated dots widget here
                          ),
                        );
                      }

                      // Normal message rendering (user or assistant)
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
                            message.contentList.first,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inverseSurface,
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