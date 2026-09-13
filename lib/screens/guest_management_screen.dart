// lib/screens/guest_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/guest_provider.dart';

class GuestManagementScreen extends StatefulWidget {
  const GuestManagementScreen({super.key});

  @override
  State<GuestManagementScreen> createState() => _GuestManagementScreenState();
}

class _GuestManagementScreenState extends State<GuestManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSide = 'All';
  final String _selectedRsvp = 'All';

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  void _applyFilter() {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    provider.fetchGuests(
      search: _searchController.text.trim(),
      side: _selectedSide,
      rsvpStatus: _selectedRsvp,
    );
  }

  void _showAddGuestModal(BuildContext context, [dynamic guest]) {
    final nameController = TextEditingController(text: guest?.guestName ?? '');
    final phoneController = TextEditingController(text: guest?.phone ?? '');
    final tagController = TextEditingController(text: guest?.familyTag ?? 'Family');
    final membersController = TextEditingController(text: guest?.memberCount.toString() ?? '1');
    String side = guest?.side ?? 'bride';
    String rsvp = guest?.rsvpStatus ?? 'pending';
    String food = guest?.foodPreference ?? 'veg';
    bool accommodation = guest?.accommodationNeeded ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guest == null ? "Add New Guest" : "Edit Guest Info", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Guest Full Name"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Mobile Phone Number"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagController,
                      decoration: const InputDecoration(labelText: "Family Group / Tag (e.g. Friends, Uncles)"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: membersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Number of Family Members"),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text("Side: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        ChoiceChip(
                          label: const Text("Bride"),
                          selected: side == 'bride',
                          onSelected: (val) => setModalState(() => side = 'bride'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Groom"),
                          selected: side == 'groom',
                          onSelected: (val) => setModalState(() => side = 'groom'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text("Food: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        ChoiceChip(
                          label: const Text("Veg"),
                          selected: food == 'veg',
                          onSelected: (val) => setModalState(() => food = 'veg'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text("Non-Veg"),
                          selected: food == 'non_veg',
                          onSelected: (val) => setModalState(() => food = 'non_veg'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text("Jain"),
                          selected: food == 'jain',
                          onSelected: (val) => setModalState(() => food = 'jain'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      title: const Text("Requires Stay / Hotel Accommodation"),
                      value: accommodation,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setModalState(() => accommodation = val ?? false),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final provider = Provider.of<GuestProvider>(context, listen: false);
                          await provider.saveGuest(
                            id: guest?.id ?? 0,
                            guestName: nameController.text,
                            phone: phoneController.text,
                            familyTag: tagController.text,
                            side: side,
                            memberCount: int.tryParse(membersController.text) ?? 1,
                            invitationStatus: 'invited',
                            rsvpStatus: rsvp,
                            foodPreference: food,
                            accommodationNeeded: accommodation,
                          );
                        },
                        child: const Text("Save Guest"),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = Provider.of<GuestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Management & RSVP"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGuestModal(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Add Guest", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Filter & Stats Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  decoration: const InputDecoration(
                    hintText: "Search guest name, phone, family group...",
                    prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: const Text("All"),
                      selected: _selectedSide == 'All',
                      onSelected: (val) {
                        setState(() => _selectedSide = 'All');
                        _applyFilter();
                      },
                    ),
                    ChoiceChip(
                      label: const Text("Bride Side"),
                      selected: _selectedSide == 'Bride',
                      onSelected: (val) {
                        setState(() => _selectedSide = 'Bride');
                        _applyFilter();
                      },
                    ),
                    ChoiceChip(
                      label: const Text("Groom Side"),
                      selected: _selectedSide == 'Groom',
                      onSelected: (val) {
                        setState(() => _selectedSide = 'Groom');
                        _applyFilter();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Guest List
          Expanded(
            child: guestProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : guestProvider.guests.isEmpty
                    ? const Center(child: Text("No guests found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: guestProvider.guests.length,
                        itemBuilder: (context, index) {
                          final g = guestProvider.guests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: g.side == 'bride' ? AppTheme.roseLight : Colors.blue.shade50,
                                child: Text(g.side == 'bride' ? "👰" : "🤵"),
                              ),
                              title: Text("${g.guestName} (${g.memberCount})", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${g.familyTag} • ${g.foodPreference.toUpperCase()} • Stay: ${g.accommodationNeeded ? 'Yes' : 'No'}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                onPressed: () => guestProvider.deleteGuest(g.id),
                              ),
                              onTap: () => _showAddGuestModal(context, g),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
