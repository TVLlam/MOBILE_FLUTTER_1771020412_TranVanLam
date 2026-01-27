import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  MemberTier? _selectedTier;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    ref.read(membersProvider.notifier).loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thành viên CLB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filter chips
          if (_selectedTier != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text('Hạng ${_getTierName(_selectedTier!)}'),
                    onDeleted: () => setState(() => _selectedTier = null),
                    deleteIconColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

          // Members list
          Expanded(
            child: membersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(membersProvider.notifier).loadMembers(),
                    child: _buildMembersList(membersState.members),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<MemberModel> members) {
    // Filter by search
    var filteredMembers = members.where((m) {
      final query = _searchController.text.toLowerCase();
      return m.fullName.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query);
    }).toList();

    // Filter by tier
    if (_selectedTier != null) {
      filteredMembers = filteredMembers
          .where((m) => m.tier == _selectedTier)
          .toList();
    }

    // Sort
    switch (_sortBy) {
      case 'name':
        filteredMembers.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'points':
        filteredMembers.sort(
          (a, b) => (b.points ?? 0).compareTo(a.points ?? 0),
        );
        break;
      case 'tier':
        filteredMembers.sort((a, b) => b.tier.index.compareTo(a.tier.index));
        break;
    }

    if (filteredMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Không tìm thấy thành viên nào'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/members/${member.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: member.avatarUrl != null
                        ? CachedNetworkImageProvider(member.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: member.avatarUrl == null
                        ? Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getTierColor(member.tier),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTierBadge(member.tier),
                        const SizedBox(width: 8),
                        Text(
                          '${member.points ?? 0} điểm',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_tennis,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${member.totalMatches ?? 0}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${member.wins ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierBadge(MemberTier tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getTierColor(tier).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getTierName(tier),
        style: TextStyle(
          color: _getTierColor(tier),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getTierColor(MemberTier tier) {
    switch (tier) {
      case MemberTier.bronze:
        return Colors.brown;
      case MemberTier.silver:
        return Colors.grey;
      case MemberTier.gold:
        return Colors.amber[700]!;
      case MemberTier.platinum:
        return Colors.blueGrey;
      case MemberTier.diamond:
        return Colors.cyan[700]!;
    }
  }

  String _getTierName(MemberTier tier) {
    switch (tier) {
      case MemberTier.bronze:
        return 'Đồng';
      case MemberTier.silver:
        return 'Bạc';
      case MemberTier.gold:
        return 'Vàng';
      case MemberTier.platinum:
        return 'Bạch Kim';
      case MemberTier.diamond:
        return 'Kim Cương';
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc', style: AppTextStyles.heading2),
              const SizedBox(height: 24),

              const Text('Hạng thành viên', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...MemberTier.values.map(
                    (tier) => ChoiceChip(
                      label: Text(_getTierName(tier)),
                      selected: _selectedTier == tier,
                      onSelected: (selected) {
                        setModalState(
                          () => _selectedTier = selected ? tier : null,
                        );
                        setState(() {});
                      },
                      selectedColor: _getTierColor(tier).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedTier == tier
                            ? _getTierColor(tier)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Sắp xếp theo', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tên'),
                    selected: _sortBy == 'name',
                    onSelected: (selected) {
                      setModalState(() => _sortBy = 'name');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Điểm'),
                    selected: _sortBy == 'points',
                    onSelected: (selected) {
                      setModalState(() => _sortBy = 'points');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Hạng'),
                    selected: _sortBy == 'tier',
                    onSelected: (selected) {
                      setModalState(() => _sortBy = 'tier');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedTier = null;
                          _sortBy = 'name';
                        });
                        setState(() {});
                      },
                      child: const Text('ĐẶT LẠI'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ĐÓNG'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
