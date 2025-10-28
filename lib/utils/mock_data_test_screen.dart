import 'package:flutter/material.dart';
import 'package:smart_cb_1/utils/mock_data_generator.dart';

class MockDataTestScreen extends StatefulWidget {
  const MockDataTestScreen({super.key});

  @override
  State<MockDataTestScreen> createState() => _MockDataTestScreenState();
}

class _MockDataTestScreenState extends State<MockDataTestScreen> {
  final MockDataGenerator _mockDataGenerator = MockDataGenerator();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Data Generator'),
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Mock Data Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Circuit Breakers Button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _generateCircuitBreakers(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Generating...'),
                      ],
                    )
                  : const Text(
                      'Generate Mock Circuit Breakers',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 20),

            // Historical Data Button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _generateHistoricalData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Generating...'),
                      ],
                    )
                  : const Text(
                      'Generate Mock Historical Data',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 20),

            // All Data Button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _generateAllData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Generating...'),
                      ],
                    )
                  : const Text(
                      'Generate All Mock Data',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 30),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage.contains('Error')
                        ? Colors.red.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This will add mock data to your Firebase Realtime Database for testing purposes. Make sure you are logged in before generating data.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCircuitBreakers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await _mockDataGenerator.generateMockCircuitBreakers();
      setState(() {
        _statusMessage = 'Mock circuit breakers generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating circuit breakers: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateHistoricalData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await _mockDataGenerator.generateMockHistoricalData();
      setState(() {
        _statusMessage = 'Mock historical data generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating historical data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await _mockDataGenerator.generateMockCircuitBreakers();
      await _mockDataGenerator.generateMockHistoricalData();
      setState(() {
        _statusMessage = 'All mock data generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating mock data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
