exports.sendFriendNotification = functions.firestore
    .document('users/{userId}/friends/{friendId}')
    .onCreate(async (snap, context) => {
        const newFriendData = snap.data();
        const fcmToken = newFriendData.fcmToken;

        if (!fcmToken) {
            console.log('No FCM token found for the new friend');
            return;
        }

        const message = {
            notification: {
                title: 'You have a new friend request',
                body: `${newFriendData.name} added you as a friend!`,
            },
            token: fcmToken,
        };

        try {
            await admin.messaging().send(message);
            console.log('Friend notification sent');
        } catch (error) {
            console.log('Error sending notification:', error);
        }
    });
