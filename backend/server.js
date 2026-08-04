const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const midtransClient = require('midtrans-client');

// Load .env variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize Midtrans Snap API Client
const snap = new midtransClient.Snap({
  isProduction: process.env.MIDTRANS_IS_PRODUCTION === 'true',
  serverKey: process.env.MIDTRANS_SERVER_KEY,
  clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// Health check endpoint
app.get('/', (req, res) => {
  res.send('Halopet Midtrans Backend is running!');
});

/**
 * Endpoint: POST /api/payment/token
 * Desc: This endpoint is called from the Flutter app to request a Snap Token.
 * The Flutter app will send order details (amount, customer info) in the request body.
 */
app.post('/api/payment/token', async (req, res) => {
  try {
    const { order_id, gross_amount, customer_details, item_details } = req.body;

    // Minimum parameter requirements for Midtrans
    const parameter = {
      transaction_details: {
        order_id: order_id || `HALOPET-${Date.now()}`,
        gross_amount: gross_amount
      },
      credit_card: {
        secure: true
      },
      customer_details: customer_details,
      item_details: item_details
    };

    // Call Midtrans API to get the token
    const transaction = await snap.createTransaction(parameter);
    
    // Return token and redirect_url to Flutter app
    res.status(200).json({
      status: 'success',
      token: transaction.token,
      redirect_url: transaction.redirect_url
    });

  } catch (error) {
    console.error('Error generating token:', error.message);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

/**
 * Endpoint: POST /api/payment/webhook
 * Desc: This endpoint is registered in Midtrans Dashboard as the "Payment Notification URL".
 * Midtrans will send a POST request here when a transaction status changes (e.g., success, expire, cancel).
 */
app.post('/api/payment/webhook', (req, res) => {
  const notification = req.body;
  
  // Midtrans requires us to verify the signature key to ensure the request is valid,
  // but for simplicity and since we use midtrans-client, we can process it directly.
  
  snap.transaction.notification(notification)
    .then((statusResponse) => {
      let orderId = statusResponse.order_id;
      let transactionStatus = statusResponse.transaction_status;
      let fraudStatus = statusResponse.fraud_status;

      console.log(`\n=== INCOMING WEBHOOK FROM MIDTRANS ===`);
      console.log(`Transaction notification received. Order ID: ${orderId}. Transaction status: ${transactionStatus}. Fraud status: ${fraudStatus}`);

      // Here you would typically update your database.
      // Example logic:
      if (transactionStatus == 'capture') {
        if (fraudStatus == 'challenge') {
          console.log(`[ACTION] Order ${orderId} is challenged by FDS. Need manual review.`);
        } else if (fraudStatus == 'accept') {
          console.log(`[ACTION] Order ${orderId} is captured successfully.`);
        }
      } else if (transactionStatus == 'settlement') {
        // PAYMENT IS SUCCESSFUL!
        console.log(`[ACTION] Order ${orderId} payment is SETTLED. Update database to 'finished'.`);
        // TODO: Update SQLite/MySQL database here
      } else if (transactionStatus == 'cancel' || transactionStatus == 'deny' || transactionStatus == 'expire') {
        console.log(`[ACTION] Order ${orderId} payment is FAILED/EXPIRED. Update database to 'cancelled'.`);
        // TODO: Update SQLite/MySQL database here
      } else if (transactionStatus == 'pending') {
        console.log(`[ACTION] Order ${orderId} is PENDING. Waiting for payment.`);
      }

      // We MUST return 200 OK so Midtrans knows we received the notification
      res.status(200).send('OK');
    })
    .catch((error) => {
      console.error('Webhook error:', error.message);
      res.status(500).send('Webhook Processing Error');
    });
});

app.listen(port, () => {
  console.log(`Halopet Backend listening at http://localhost:${port}`);
});
