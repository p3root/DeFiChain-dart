import 'dart:convert';
// 导入 Uint8List
import 'dart:typed_data';
// 导入 SHA256Digest
import 'package:pointycastle/digests/sha256.dart';
// 导入 RIPEMD160Digest
import 'package:pointycastle/digests/ripemd160.dart';

import '../lib/src/models/networks.dart' as NETWORKS;
import '../lib/src/payments/p2pkh.dart' show P2PKH;
import '../lib/src/payments/p2wpkh.dart' show P2WPKH;
import '../lib/src/payments/index.dart' show PaymentData;
import 'package:bs58check/bs58check.dart' as bs58check;

import '../lib/src/ecpair.dart' show ECPair;

import 'package:bech32/bech32.dart';
import '../lib/src/transaction_builder.dart';

rng(int number) {
  return utf8.encode('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
}

rngKeybag(int number) {
  return utf8.encode('zzzzzzzzzzzzzzzzzzzzzzzzzzkeybag');
}

Uint8List hash160(Uint8List buffer) {
  Uint8List _tmp = new SHA256Digest().process(buffer);
  return new RIPEMD160Digest().process(_tmp);
}

// 通过原始方式创建地址
createAddressInOriginalWay() {
  final keyPair = ECPair.makeRandom(rng: rng);
  print(keyPair.publicKey);
  print(keyPair.publicKey.length);
  // pubkey：Uint8List 格式的公钥
  var hash = hash160(keyPair.publicKey);
  print(hash);
  print(hash.length);
  final payload = new Uint8List(21);
  payload.buffer.asByteData().setUint8(0, 0x00);
  payload.setRange(1, payload.length, hash);
  print(payload);
  var address = bs58check.encode(payload);
  print(address);
}

// 创建交易
createTransaction() {
  final alice =
      ECPair.fromWIF('L2uPYXe17xSTqbCjZvL2DsyXPCbXspvcu5mHLDYUgzdUbZGSKrSr');
  final address2 =
      new P2PKH(data: new PaymentData(pubkey: alice.publicKey)).data.address;
  print(address2);
  final txb = new TransactionBuilder();

  txb.setVersion(2);
  txb.addInput(
      '7d067b4a697a09d2c3cff7d4d9506c9955e93bff41bf82d439da7d030382bc3e',
      0); // Alice's previous transaction output, has 15000 satoshis
  txb.addOutput('1KRMKfeZcmosxALVYESdPNez1AP1mEtywp', 80000);
  // (in)90000 - (out)80000 = (fee)10000, this is the miner fee

  txb.sign(vin: 0, keyPair: alice);

  print(txb.build().toHex());

  // 02000000013ebc8203037dda39d482bf41ff3be955996c50d9d4f7cfc3d2097a694a7b067d000000006b483045022100931b6db94aed25d5486884d83fc37160f37f3368c0d7f48c757112abefec983802205fda64cff98c849577026eb2ce916a50ea70626a7669f8596dd89b720a26b4d501210365db9da3f8a260078a7e8f8b708a1161468fb2323ffda5ec16b261ec1056f455ffffffff0180380100000000001976a914ca0d36044e0dc08a22724efa6f6a07b0ec4c79aa88ac00000000
}

// 创建Testnet地址
Map<String, dynamic> createTestnetAddress(Function rng) {
  final testnet = NETWORKS.testnet;
  final keyPair = ECPair.makeRandom(network: testnet, rng: rng);
  final wif = keyPair.toWIF();
  final address = new P2PKH(
          data: new PaymentData(pubkey: keyPair.publicKey), network: testnet)
      .data
      .address;
  print(wif);
  print(address);

  return {
    'wif': wif,
    'address': address,
  };
}

createTestnetTransaction(String txHash) {
  final keybag =
      ECPair.fromWIF('cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5MHjaqzhL42Cse1T');
  final address = new P2PKH(
          data: new PaymentData(pubkey: keybag.publicKey),
          network: NETWORKS.testnet)
      .data
      .address;
  print(address);
  final txb = new TransactionBuilder(network: NETWORKS.testnet);

  txb.setVersion(1);
  txb.addInput(
      txHash, 0); // Keybag's previous transaction output, has 15000 satoshis
  txb.addOutput('mubSzQNtZfDj1YdNP6pNDuZy6zs6GDn61L', 1230);
  // (in)90000 - (out)80000 = (fee)10000, this is the miner fee

  txb.sign(vin: 0, keyPair: keybag);

  print(txb.build().toHex());
}

main() {
  // createAddressInOriginalWay();

  // createTestnetAddress(rng);

  // createTestnetAddress(rngKeybag);
  // wif: cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5MHjaqzhL42Cse1T
  // address: msXCejAWLAPZym8JK2516x7gbu3giKWUP3

  // createTestnetTransaction('ebfff962a44bed1387ac62d40f6636c11e05be7038eb7a96ffe410b1d13100bb');

  createTransaction();
}