import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PointsPage extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points and Rewards',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final currentPoints = data?['currentPoints'] ?? 0;
          final totalPoints = data?['totalPoints'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TierProgressCard(
                      totalPoints: totalPoints, currentPoints: currentPoints),
                  const SizedBox(height: 20),
                  const Text(
                    'Available Rewards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  RewardsGrid(
                    currentPoints: currentPoints,
                    totalPoints: totalPoints, // Added this line
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TierProgressCard extends StatelessWidget {
  final int totalPoints;
  final int currentPoints;

  const TierProgressCard({
    super.key,
    required this.totalPoints,
    required this.currentPoints,
  });

  String getCurrentTier() {
    if (totalPoints >= 60000) return 'Diamond';
    if (totalPoints >= 40000) return 'Gold';
    if (totalPoints >= 20000) return 'Silver';
    return 'Bronze';
  }

  String getNextTier() {
    if (totalPoints >= 60000) return 'Diamond';
    if (totalPoints >= 40000) return 'Diamond';
    if (totalPoints >= 20000) return 'Gold';
    return 'Silver';
  }

  int getPointsToNextTier() {
    if (totalPoints >= 60000) return 0;
    if (totalPoints >= 40000) return 60000 - totalPoints;
    if (totalPoints >= 20000) return 40000 - totalPoints;
    return 20000 - totalPoints;
  }

  Color getTierColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return Colors.blue[100]!;
      case 'Gold':
        return Colors.yellow[700]!;
      case 'Silver':
        return Colors.grey[400]!;
      default:
        return Colors.brown[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rewards Tier',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total Points: ${totalPoints.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(Icons.star,
                        color: getTierColor(getCurrentTier()), size: 24),
                    Text(getCurrentTier(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.star,
                        color: getTierColor(getNextTier()), size: 24),
                    Text(getNextTier(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    getTierColor(getCurrentTier()),
                    getTierColor(getNextTier())
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: totalPoints % 20000 / 20000,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${getPointsToNextTier().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )} points needed',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Redeemable Points',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentPoints.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Reward {
  final String name;
  final String description;
  final int points;
  final IconData image;
  final String tier; // Added tier property

  Reward({
    required this.name,
    required this.description,
    required this.points,
    required this.image,
    required this.tier,
  });
}

class RewardsGrid extends StatelessWidget {
  final int currentPoints;
  final int totalPoints;

  const RewardsGrid({
    super.key,
    required this.currentPoints,
    required this.totalPoints,
  });

  String getCurrentTier() {
    if (totalPoints >= 60000) return 'Diamond';
    if (totalPoints >= 40000) return 'Gold';
    if (totalPoints >= 20000) return 'Silver';
    return 'Bronze';
  }

  bool hasTierAccess(String tier) {
    // Use totalPoints for tier access
    switch (tier) {
      case 'Bronze':
        return true;
      case 'Silver':
        return totalPoints >= 20000;
      case 'Gold':
        return totalPoints >= 40000;
      case 'Diamond':
        return totalPoints >= 60000;
      default:
        return false;
    }
  }

  List<Reward> getAllRewardsOrganizedByTier() {
    return [
      Reward(
        name: 'Chick-fil-A Gift Card',
        description: '\$5 off any purchase',
        points: 5000,
        image: Icons.card_giftcard,
        tier: 'Bronze',
      ),
      Reward(
        name: 'McDonald\'s Gift Card',
        description: '\$5 off any purchase',
        points: 5000,
        image: Icons.card_giftcard,
        tier: 'Bronze',
      ),
      // Bronze Tier Rewards (available to everyone)
      Reward(
        name: 'Chipotle Gift Card',
        description: '\$5 off any purchase',
        points: 10000,
        image: Icons.card_giftcard,
        tier: 'Bronze',
      ),
      Reward(
        name: 'Panera Gift Card',
        description: '\$5 off any purchase',
        points: 10000,
        image: Icons.card_giftcard,
        tier: 'Bronze',
      ),
      // Silver Tier Rewards
      Reward(
        name: 'Dunkin\' Gift Card',
        description: '\$5 off any purchase',
        points: 20000,
        image: Icons.card_giftcard,
        tier: 'Silver',
      ),
      Reward(
        name: 'Walmart Gift Card',
        description: '\$5 off any purchase',
        points: 20000,
        image: Icons.card_giftcard,
        tier: 'Silver',
      ),
      Reward(
        name: 'Starbucks Gift Card',
        description: '\$10 off any purchase',
        points: 40000,
        image: Icons.card_giftcard,
        tier: 'Gold',
      ),
      Reward(
        name: 'Target Gift Card',
        description: '\$10 off any purchase',
        points: 40000,
        image: Icons.card_giftcard,
        tier: 'Gold',
      ),
      Reward(
        name: 'Apple Gift Card',
        description: '\$20 off any purchase',
        points: 60000,
        image: Icons.card_giftcard,
        tier: 'Diamond',
      ),
      Reward(
        name: 'Amazon Gift Card',
        description: '\$20 off any purchase',
        points: 60000,
        image: Icons.card_giftcard,
        tier: 'Diamond',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allRewards = getAllRewardsOrganizedByTier();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      children: [
        for (final reward in allRewards)
          RewardCard(
              name: reward.name,
              description: reward.description,
              points: reward.points,
              image: reward.image,
              currentPoints: currentPoints,
              hasTierAccess: hasTierAccess(reward.tier),
              canRedeem:
                  hasTierAccess(reward.tier) && currentPoints >= reward.points,
              tier: reward.tier // Modified this line
              ),
      ],
    );
  }
}

class RewardCard extends StatelessWidget {
  final String name;
  final String description;
  final int points;
  final IconData image;
  final int currentPoints;
  final bool hasTierAccess;
  final bool canRedeem;
  final String tier; // Add tier parameter

  const RewardCard({
    super.key,
    required this.name,
    required this.description,
    required this.points,
    required this.image,
    required this.currentPoints,
    required this.hasTierAccess,
    required this.canRedeem,
    required this.tier, // Add this
  });

  Color getTierColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return Colors.blue[100]!;
      case 'Gold':
        return Colors.yellow[700]!;
      case 'Silver':
        return Colors.grey[400]!;
      default:
        return Colors.brown[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        // Wrap Padding with Stack to overlay the tier indicator
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  image,
                  size: 50,
                  color: hasTierAccess ? null : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasTierAccess ? null : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: hasTierAccess ? null : Colors.grey,
                  ),
                ),
                Text(
                  '${points.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} points',
                  style: TextStyle(
                    color: hasTierAccess ? null : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: canRedeem
                      ? () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({
                              'currentPoints': FieldValue.increment(-points)
                            });

                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: TweenAnimationBuilder(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(seconds: 1),
                                    builder: (context, value, child) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 50 * (value),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Reward Redeemed!',
                                            style: TextStyle(
                                                fontSize: 20 * value,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Check your email for the coupon code',
                                            style: TextStyle(
                                                fontSize: 14 * value,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close',
                                          style: TextStyle(color: Colors.blue)),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: canRedeem ? null : Colors.grey[300],
                  ),
                  child: const Text('Redeem'),
                ),
              ],
            ),
          ),
          Positioned(
            // Add tier indicator in top-right corner
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: getTierColor(tier),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
