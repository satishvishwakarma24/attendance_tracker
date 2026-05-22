import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isPunchedIn = false;
  DateTime? _lastPunchTime;

  void _handlePunchAction() {
    setState(() {
      _isPunchedIn = !_isPunchedIn;
      _lastPunchTime = DateTime.now();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPunchedIn 
          ? 'Punched In safely at Office Zone' 
          : 'Punched Out safely'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0050CB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDm834hPlRb5ruEPBNbrAEeQBHD88X3vXLJeRxSsN_2XC3U-rpVYq9VKdTRp-h0ULfXbz8BcT4D5CfmtVumTSNAepRkWOGOR1frhu-Q9uJMQ7A2AiA1J7Kgyxa3n9BusJBOnM-LAqlCXemJKRSpd1JjqRWcD8TPOeh-JiHOz1HN1ZrbpBGDLCTrtUSfU_wZhRJIfq-kZLJZRd0pGpXICFn8mkIOiEuy49fRnokclok4B4RDQ9h9PEclPHY4v-1BBiwX32KmEQShsPkJ'
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'WorkSync',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0050CB),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF424656)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Hi, Alex Johnson',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ready for a productive day?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Color(0xFF424656),
              ),
            ),
            const SizedBox(height: 24),

            // Hero Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3E4FE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D0066FF),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPunchedIn ? Icons.door_back_door_outlined : Icons.sensor_door,
                      size: 32,
                      color: const Color(0xFF0050CB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isPunchedIn ? 'Punched In' : 'Punched Out',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'CURRENT STATUS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Color(0xFF424656),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1ADDE3EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isPunchedIn ? Colors.green : const Color(0xFF727687),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPunchedIn 
                              ? 'Active since Today 09:00 AM'
                              : 'Inactive since Yesterday 5:00 PM',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E656D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location Verification Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3E4FE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D0066FF),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB7EAFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Color(0xFF004E60),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Inside Office Zone',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Location verified successfully',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF424656),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF727687),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Fingerprint Punch Action Button
            ElevatedButton(
              onPressed: _handlePunchAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0050CB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                elevation: 4,
                shadowColor: const Color(0x330050CB),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    _isPunchedIn ? 'Punch Out' : 'Punch In',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to record your workspace clocking time',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF424656),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}