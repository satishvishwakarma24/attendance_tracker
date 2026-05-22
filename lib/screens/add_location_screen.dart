import 'package:flutter/material.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({Key? key}) : super(key: key);

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController(text: '40.7128');
  final _lngController = TextEditingController(text: '-74.0060');
  double _radius = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424656)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Location',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0050CB),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // Map Preview Simulation
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3E4FE)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBd_oFgQAyFXrYLfjhr5G8uCXM5BTMSqSG-EZfRH8_U4Z8Ec8TeMvPvNqwtwDwZ1LnyK_MdjTzVnvqYAcq8XWAj4kNwyKPr93BiYFjWyFj4TT941_BbACsKdAL_yRCA-stwF_vZHpWoEN_UCyUGD_8nNWU7YV8b0TjQtgxDTX4x5pLwakWmd_DoQCMvMm4QJFldbAu5div0Bg8FH5aDzO8yIFBjuMxgFi84hiz4Iayo4zHsd9ImZlFPktuhy4ZzhXsEL7AQy8jxbIGm'
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated Geofence Ring sizing dynamically based on radius
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 50 + (_radius * 0.3),
                    height: 50 + (_radius * 0.3),
                    decoration: BoxDecoration(
                      color: const Color(0x330050CB),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x800050CB), width: 2),
                    ),
                    child: const Icon(
                      Icons.location_on, 
                      color: Color(0xFF0050CB), 
                      size: 28,
                    ),
                  ),
                  // GPS Pill
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEFF4FF)),
                      ),
                      child: const Row(
                        children:  [
                          Icon(Icons.my_location, size: 14, color: Color(0xFF0050CB)),
                          SizedBox(width: 6),
                          Text(
                            'GPS Active',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Office Name',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424656),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Headquarters',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC2C6D8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC2C6D8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Latitude and Longitude Grid
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latitude',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF424656),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _latController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFC2C6D8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Longitude',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF424656),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _lngController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFC2C6D8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Radius Slider Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Geofence Radius (meters)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424656),
                        ),
                      ),
                      Text(
                        '${_radius.toInt()}m',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0050CB),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 10,
                    max: 500,
                    activeColor: const Color(0xFF0050CB),
                    inactiveColor: const Color(0xFFEFF4FF),
                    onChanged: (val) => setState(() => _radius = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('10m', style: TextStyle(fontSize: 12, color: Color(0xFF727687))),
                      Text('500m', style: TextStyle(fontSize: 12, color: Color(0xFF727687))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Persistent Persistent Button Action
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an office name')),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0050CB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Save Location',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}