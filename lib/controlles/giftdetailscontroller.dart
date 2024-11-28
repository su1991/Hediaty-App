
import '../database/databasehelp.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';



class GiftController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> saveGift(Gift gift) async
  {
    // Convert Gift object to Map and save it
    final giftMap = gift.toMap();
    return await _databaseHelper.insertGift(giftMap);
  }

  Future<List<Gift>> getAllGifts() async
  {
    final giftMaps = await _databaseHelper.getGifts();
    return giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
  }
}

