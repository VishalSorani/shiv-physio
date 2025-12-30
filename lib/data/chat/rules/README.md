# Firebase Security Rules for Chat Functionality

This directory contains the Firebase security rules for the chat functionality in the mobile app.

## Rules File

The `firestore_rules.txt` file contains the complete set of security rules for Firestore. These rules ensure that:

1. Only authenticated users can access the database
2. Users can only access conversations they are participants in
3. Users can only update their own data
4. Admins and moderators have additional privileges

## Key Changes

The most important change in these rules is the fix for the "mark messages as read" functionality. The original rules didn't explicitly allow participants to update the `readStatus` field of messages, which caused the permission error:

```
Error marking messages as read: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

The updated rules now include this condition in the message update rule:

```javascript
(isConversationParticipant(conversationId) && 
 request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readStatus.' + request.auth.uid]))
```

This allows conversation participants to update only the `readStatus` field for their own user ID.

## How to Deploy

To deploy these rules to Firebase, follow these steps:

1. Install the Firebase CLI if you haven't already:
   ```
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```
   firebase init
   ```

4. Deploy the rules:
   ```
   firebase deploy --only firestore:rules
   ```

Alternatively, you can deploy the rules directly from the Firebase Console:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Firestore Database > Rules
4. Copy and paste the contents of `firestore_rules.txt`
5. Click "Publish"

## Testing the Rules

After deploying the rules, test the "mark messages as read" functionality to ensure the permission error is resolved. If you encounter any issues, check the Firebase Console logs for more detailed error messages. 