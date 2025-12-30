# Chat Module

A comprehensive chat functionality implementation for Flutter applications using Firebase services (Firestore and Storage).

## Features

- 💬 **Regular and Group Chat** - Support for both 1:1 conversations and group chats
- 📸 **Rich Media** - Send text, images, videos, audio, files, and other content types
- 🚫 **Blocking** - Block users in 1:1 conversations
- 🟢 **Online Status** - Track user presence with online/offline indicators
- ✓ **Read/Unread** - Message read status and unread message counts
- ⌨️ **Typing Indicators** - Real-time typing status updates
- 📃 **Pagination** - Load messages in batches for better performance
- 📤 **File Upload** - Upload images, documents, and other files
- 🚩 **Reporting** - Report inappropriate messages or conversations
- 👮 **Moderation** - Admin and moderator roles for group management

## Implementation Structure

### Models

- `BaseConversationModel` - Enhanced conversation model with participant data and chat users
- `BaseConversationParticipant` - Represents a user's data within a conversation
- `ChatMessage` - Represents a message in a conversation
- `ChatUser` - User profile model for chat functionality
- `LastMessage` - Represents the last message in a conversation
- `ChatReport` - Represents a reported message or conversation

### Enums

- `MessageType` - Defines the types of messages (text, image, file, etc.)
- `ParticipantRole` - Defines user roles in group chats (admin, moderator, member, etc.)
- `ReportType` - Defines types of reports
- `ReportStatus` - Defines the status of a report

### Client Interface and Implementation

- `ChatConversationClient` - Abstract class defining all chat operations
- `FirebaseChatClient` - Implementation using Firebase services

### Repository and Service Layer

- `ChatRepository` - Interacts with the chat client
- `ChatService` - Business logic for chat features (used by the UI)

## Setup Instructions

### 1. Add Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  cloud_firestore: ^5.6.6
  firebase_storage: ^12.4.5
  firebase_auth: ^5.5.0
  get: ^4.6.6
  path: ^1.8.3
```

### 2. Firebase Configuration

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS apps to the project
3. Download and add the Google Services configuration files
4. Initialize Firebase in your app's `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 3. Firestore Security Rules

Set up the following security rules in your Firebase project:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isUserAuthenticated(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isConversationParticipant(conversationId) {
      let conversation = get(/databases/$(database)/documents/conversations/$(conversationId));
      return isAuthenticated() && 
             request.auth.uid in conversation.data.participantIds;
    }
    
    function isConversationAdmin(conversationId) {
      let conversation = get(/databases/$(database)/documents/conversations/$(conversationId));
      return isAuthenticated() && 
             (conversation.data.adminId == request.auth.uid || 
             conversation.data.participantData[request.auth.uid].role == "admin");
    }
    
    function isConversationModerator(conversationId) {
      let conversation = get(/databases/$(database)/documents/conversations/$(conversationId));
      return isAuthenticated() && 
             conversation.data.participantData[request.auth.uid].role == "moderator";
    }
    
    function canAdministerConversation(conversationId) {
      return isConversationAdmin(conversationId) || isConversationModerator(conversationId);
    }
    
    function isMessageSender(conversationId, messageId) {
      let message = get(/databases/$(database)/documents/conversations/$(conversationId)/messages/$(messageId));
      return isAuthenticated() && 
             message.data.senderId == request.auth.uid;
    }
    
    // User profiles
    match /users/{userId} {
      // Anyone can read basic user profiles
      allow read: if isAuthenticated();
      
      // Users can only update their own profile
      allow create, update, delete: if isUserAuthenticated(userId);
    }
    
    // Conversations
    match /conversations/{conversationId} {
      // Only participants can read a conversation
      allow read: if isConversationParticipant(conversationId);
      
      // Any authenticated user can create a conversation
      allow create: if isAuthenticated() && 
                      request.resource.data.participantIds.hasAll([request.auth.uid]);
      
      // Only admins/moderators can update conversation details
      allow update: if isConversationParticipant(conversationId) && (
                       // Participants can update only their own data
                       request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['participantData.' + request.auth.uid]) ||
                       // Or admins/moderators can make broader changes
                       canAdministerConversation(conversationId)
                     );
      
      // Only admins can delete a conversation
      allow delete: if isConversationAdmin(conversationId);
      
      // Messages within a conversation
      match /messages/{messageId} {
        // Only participants can read messages in a conversation
        allow read: if isConversationParticipant(conversationId);
        
        // Only participants can send messages
        allow create: if isConversationParticipant(conversationId) && 
                        request.resource.data.senderId == request.auth.uid;
        
        // Message owners can edit their own messages, admins can delete any message
        allow update: if (isMessageSender(conversationId, messageId) && 
                         !request.resource.data.diff(resource.data).affectedKeys().hasAny(['senderId', 'conversationId', 'timestamp'])) || 
                        canAdministerConversation(conversationId);
        
        // Only message sender or admins can delete a message
        allow delete: if isMessageSender(conversationId, messageId) || 
                        canAdministerConversation(conversationId);
      }
    }
    
    // Reports
    match /reports/{reportId} {
      // Any authenticated user can create a report
      allow create: if isAuthenticated() && 
                      request.resource.data.reportedBy == request.auth.uid;
      
      // Only the reporter can read their own reports
      allow read: if isAuthenticated() && 
                    resource.data.reportedBy == request.auth.uid;
      
      // No one can update or delete reports directly (admin-only via functions)
      allow update, delete: if false;
    }
    
    // Default deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 4. GetX Dependency Injection Setup

Set up the chat dependencies in your app using GetX:

```dart
void main() {
  runApp(
    GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        // Auth providers
        Get.put<AuthenticationClient>(FirebaseAuthClient());
        
        // Chat providers
        Get.put<ChatConversationClient>(FirebaseChatClient());
        Get.put<ChatRepository>(ChatRepository(Get.find<ChatConversationClient>()));
        Get.put<ChatService>(ChatService(
          Get.find<ChatRepository>(),
          Get.find<AuthRepository>(),
        ));
        
        // Controllers
        Get.put<ConversationController>(ConversationController(
          userRepository: Get.find<UserRepository>(),
          navigationService: Get.find<NavigationService>(),
          chatService: Get.find<ChatService>(),
        ));
      }),
      home: const HomeScreen(),
    ),
  );
}
```

## Usage Examples

### Initialize the Chat Service

```dart
// The service is already initialized through GetX
final chatService = Get.find<ChatService>();
```

### Create a New Conversation

```dart
// Create a 1:1 conversation
final conversation = await chatService.getOrCreateDirectConversation(otherUserId);

// Create a group conversation
final groupConversation = await chatService.createGroupConversation(
  [user1Id, user2Id, user3Id],
  'Project Team',
);
```

### Send Messages

```dart
// Send a text message
await chatService.sendTextMessage(conversationId, 'Hello, world!');

// Send an image
await chatService.sendImageMessage(conversationId, imageFile);

// Send a file
await chatService.sendFileMessage(
  conversationId,
  file,
  'report.pdf',
  'application/pdf',
);
```

### Load Messages

```dart
// Get the latest messages
final messages = await chatService.getMessages(conversationId);

// Load more messages with pagination
final olderMessages = await chatService.getMessages(
  conversationId,
  lastMessageId: messages.last.id,
);
```

### Listen to Updates

```dart
// Listen to new messages
chatService.listenToMessages(conversationId).listen((messages) {
  // Update UI with new messages
});

// Listen to conversation updates (typing, read status, etc.)
chatService.listenToAllConversations().listen((conversations) {
  // Update UI with conversation changes
});
```

### Group Management

```dart
// Add a user to a group
await chatService.addUserToGroup(conversationId, newUserId);

// Make a user an admin
await chatService.makeUserAdmin(conversationId, userId);

// Leave a group
await chatService.leaveGroup(conversationId);
```

### User Blocking

```dart
// Block a user
await chatService.blockUser(conversationId, otherUserId);

// Unblock a user
await chatService.unblockUser(conversationId, otherUserId);
```

## Database Structure

### Collections

- **users**: User profiles and settings
- **conversations**: Chat conversations (groups and 1:1)
- **conversations/{conversationId}/messages**: Messages within a conversation
- **reports**: User reports for conversations or messages

## Stream-Based Architecture

The chat module uses a stream-based architecture for real-time updates:

1. **BaseConversationModel**: Enhanced model that combines conversation data with participant information and chat users
2. **Stream Controllers**: Used in ChatService to broadcast updates to UI components
3. **Reactive Variables**: GetX's Rx variables for state management
4. **Listeners**: UI components listen to streams for real-time updates

This architecture ensures that all UI components stay in sync with the latest data from Firebase.

### Thanks you.