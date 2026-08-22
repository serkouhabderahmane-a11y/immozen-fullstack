import 'package:immozen/utils/payment/gatways/paypal_pay.dart';
import 'package:immozen/utils/payment/gatways/paystack_pay.dart';
import 'package:immozen/utils/payment/gatways/razorpay_pay.dart';
import 'package:immozen/utils/payment/gatways/stripe_pay.dart';
import 'package:immozen/utils/payment/lib/gatway.dart';

Paystack paystack = Paystack();

List<Gatway> gatways = [
  Gatway(key: 'stripe', instance: Stripe()),
  // Gatway(key: 'paypal', instance: Paypal()),
  Gatway(key: 'paystack', instance: paystack),
  Gatway(key: 'razorpay', instance: RazorpayPay()),
];
