/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const formatWeeks = ["日", "月", "火", "水", "木", "金", "土"]

const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()
const firestore = admin.firestore()

exports.planAlertMessages = functions.region('asia-northeast1')
    .runWith({memory: '512MB'})
    .pubsub.schedule('every 1 minutes')
    .timeZone('Asia/Tokyo')
    .onRun(async (context) => {

    //現在時刻
    const now = (() => {
        let s = admin.firestore.Timestamp.now().seconds
        s = s - s % 60
        return new admin.firestore.Timestamp(s, 0)
    })()

    //DB取得
    const planRef = firestore.collection('plan')
    const groupRef = firestore.collection('companyGroup')
    const userRef = firestore.collection('user')
    const planSnapshot = await planRef
        .where('alertMinute', '!=', 0)
        .where('alertedAt', '==', now)
        .get()
    if (!planSnapshot.empty) {
        planSnapshot.forEach(async planDoc => {
            var companyId = planDoc.data()['companyId']
            var groupId = planDoc.data()['groupId']
            var userId = planDoc.data()['userId']
            var subject = planDoc.data()['subject']
            if (userId != '') {
                const userSnapshot = await userRef
                    .where('id', '==', userId).get()
                if (!userSnapshot.empty) {
                    userSnapshot.forEach(async userDoc => {
                        var token = userDoc.data()['token']
                        admin.messaging().send(pushMessage(
                            token,
                            subject,
                            'もうすぐ予定時刻になります。',
                        ))
                    })
                }
            } else {
                const groupSnapshot = await groupRef
                    .where('companyId', '==', companyId)
                    .where('id', '==', groupId).get()
                if (!groupSnapshot.empty) {
                    groupSnapshot.forEach(async groupDoc => {
                        var userIds = groupDoc.data()['userIds']
                        if (!userIds.empty) {
                            for (i = 0; i < userIds.length; i++) {
                                var userId = userIds[i]
                                const userSnapshot = await userRef.where('id', '==', userId).get()
                                if (!userSnapshot.empty) {
                                    userSnapshot.forEach(async userDoc => {
                                        var token = userDoc.data()['token']
                                        admin.messaging().send(pushMessage(
                                            token,
                                            subject,
                                            'もうすぐ予定時刻になります。',
                                        ))
                                    })
                                }
                            }
                        }
                    })
                }
            }
        })
    }
})

const pushMessage = (token, title, body) => ({
    notification: {
        title: title,
        body: body,
    },
    apns: {
        headers: {'apns-priority': '10'},
        payload: {
            aps: {
                badge: 1,
                sound: 'default',
            },
        },
    },
    token: token,
})