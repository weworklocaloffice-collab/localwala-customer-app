import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/core/models/reel_model.dart';

Map<String, dynamic> feedItem() {
  return {
    '_id': 'r123',
    'id': 'r123',
    'videoUrl': 'https://cdn.example.com/reels/r123-720p.mp4',
    'thumbnail': 'https://cdn.example.com/reels/r123-thumb.jpg',
    'description': 'Fresh biryani drop',
    'hashtags': ['biryani', 'hyderabad'],
    'likes': 245,
    'saves': 12,
    'shares': 4,
    'comments': 9,
    'vertical': 'FOOD',
    'target': {'type': 'PRODUCT', 'refId': '507f1f77bcf86cd799439011'},
    'cta': {'label': 'ORDER NOW', 'overridden': false},
    'likesCount': 245,
    'socialProof': {
      'people': [
        {
          'userId': 'u123',
          'name': 'Rahul',
          'avatarUrl': 'https://cdn.example.com/a/rahul.jpg',
        },
        {'userId': 'u456', 'name': 'Priya', 'avatarUrl': null},
      ],
      'total': 2,
    },
  };
}

void main() {
  group('ReelModel.fromJson — backend feed shape', () {
    test('parses content, counts, target, CTA and proof', () {
      final reel = ReelModel.fromJson(feedItem());

      expect(reel.id, 'r123');
      expect(reel.videoUrl, contains('720p.mp4'));
      expect(reel.caption, 'Fresh biryani drop');
      expect(reel.hashtags, ['biryani', 'hyderabad']);
      expect(reel.likesCount, 245);
      expect(reel.vertical, 'FOOD');
      expect(reel.target.type, 'PRODUCT');
      expect(reel.target.refId, '507f1f77bcf86cd799439011');
      expect(reel.cta.label, 'ORDER NOW');
      expect(reel.cta.overridden, isFalse);
      expect(reel.socialProof.total, 2);
      expect(reel.socialProof.displayText(), 'Rahul and Priya liked this');
    });

    test('tolerates missing optionals', () {
      final reel = ReelModel.fromJson({
        'id': 'r9',
        'videoUrl': 'https://cdn.example.com/x.mp4',
      });

      expect(reel.caption, isNull);
      expect(reel.hashtags, isEmpty);
      expect(reel.likesCount, 0);
      expect(reel.cta.label, '');
      expect(reel.socialProof.displayText(), '');
    });

    test('copyWith applies interaction results', () {
      final updated = ReelModel.fromJson(
        feedItem(),
      ).copyWith(liked: true, likesCount: 246);

      expect(updated.liked, isTrue);
      expect(updated.likesCount, 246);
      expect(updated.id, 'r123');
    });
  });

  group('ReelsFeedPage', () {
    test('parses pagination envelope', () {
      final page = ReelsFeedPage.fromJson({
        'results': [feedItem(), feedItem()],
        'page': 1,
        'totalPages': 3,
        'totalResults': 27,
      });

      expect(page.items.length, 2);
      expect(page.hasMore, isTrue);
    });
  });
}
