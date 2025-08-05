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
  final String title = "Threads";

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final _controller = TextEditingController();
  final ThreadService _threadService = ThreadService();
  List<ChatMessage> _messages = [];
  Map<String, String> _threads = {}; // {threadId: title}
  String _currentThreadId = "";

  @override
  void initState() {
    super.initState();
    _loadChatAndSetState();
  }

  Future<void> _loadChatAndSetState() async {
    final List<String>? threadIds = await _threadService.getThreads();
    if (threadIds != null && threadIds.isNotEmpty) {
      setState(() {
        _threads = {
          for (int i = 0; i < threadIds.length; i++)
            threadIds[i]: 'Thread ${i + 1}'
        };
      });

      // Check if the threads already have a title. if they have it save it in the map
      _threads.forEach((threadId, title) async {
        String? title = await _threadService.getTitle(threadId);
        if (title != null) {
          log("Found title for thread $threadId: $title");
          _threads[threadId] = title;
        }
      });

      _selectThread(_threads.keys.first);
    }
  }
  Future<void> _selectThread(String threadId) async {
    if (_currentThreadId == threadId) return;

    _currentThreadId = threadId;
    final List<ChatMessage>? loadedMessages = await _threadService.getMessages(_currentThreadId);
    if (loadedMessages != null) {
      setState(() {
        _messages = loadedMessages;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isFirstMessage = _messages.isEmpty;

    final userMessage = ChatMessage(role: Role.user, contentList: [text]);
    setState(() {
      _messages.add(userMessage);
    });

    _controller.clear();

    // Send message and get runId
    String runId = await _threadService.send(_currentThreadId, userMessage);
    log('Run ID: $runId');

    // Add loading placeholder
    setState(() {
      _messages.add(ChatMessage(role: Role.assistant, contentList: ['typing']));
    });

    // Poll until run is complete
    RunStatus? status;
    do {
      await Future.delayed(Duration(seconds: 2));
      status = await _threadService.getRunStatus(_currentThreadId, runId);
    } while (status != RunStatus.completed);

    // Fetch latest messages after completion
    final updatedMessages = await _threadService.getMessages(_currentThreadId);

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

    // Get the threads title
    if (isFirstMessage || _threads[_currentThreadId] == "New Thread") {
      String? title = await _threadService.getTitle(_currentThreadId);
      if (title != null) {
        setState(() {
          _threads[_currentThreadId] = title;
        });
      }
      else {
        log("Title is null");
      }
    }
  }
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? filePickerResult = await pickFile();
    if (filePickerResult != null) {
      // File is not null. Upload it to our backend
      PlatformFile platformFile = filePickerResult.files.first;
      Uint8List? bytes = platformFile.bytes;

      if (bytes != null && bytes.isNotEmpty) {
        _threadService.file(bytes);
      }
    }

  }

  Future<void> _createThread() async {
    final String? threadId = await _threadService.createThread();
    if (threadId != null) {
      setState(() {
        _threads[threadId] = 'New Thread';
      });
      _selectThread(threadId);
    } else {
      log("ERROR: Got null from createThread()");
    }
  }
  Future<void> _deleteThread(String threadId) async {
    final bool deleted = await _threadService.delete(threadId);
    if (deleted) {
      setState(() {
        _threads.remove(threadId);

        if (_currentThreadId == threadId) {
          _messages.clear();
        }
      });
    }
  }
  Future<void> _renameThread(String threadId) async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Theme.of(context).colorScheme.primary,),
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _createThread,
                    icon: Icon(Icons.add),
                    label: Text('New Thread'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                      backgroundColor: Theme.of(context).colorScheme.primary // sets icon + text color
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _threads.length,
                    itemBuilder: (context, index) {
                      final threadId = _threads.keys.elementAt(index);
                      final threadTitle = _threads[threadId] ?? threadId;

                      return GestureDetector(
                        onSecondaryTapDown: (details) {
                          // Right-click on desktop or long-press on mobile (depending on platform)
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              0,
                              details.globalPosition.dy,
                              0,
                              0,
                            ),
                            items: [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ).then((value) {
                            if (value == 'rename') _renameThread(threadId);
                            if (value == 'delete') _deleteThread(threadId);
                          });
                        },
                        child: ListTile(
                          title: Text(threadTitle),
                          onTap: () => _selectThread(threadId),
                        ),
                      );
                    },
                  ),
                ),
              ],
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