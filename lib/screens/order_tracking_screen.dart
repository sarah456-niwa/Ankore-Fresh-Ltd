// lib/screens/order_tracking_screen.dart
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _order;
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _refreshOrderStatus();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _refreshOrderStatus() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    final updatedOrder = await _orderService.getOrderDetails(_order.id);
    if (updatedOrder != null && mounted) {
      setState(() {
        _order = updatedOrder;
      });
    }
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order ${_order.orderNumber}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _refreshOrderStatus,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrderStatus,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Progress Card
              _buildDeliveryProgressCard(),
              
              const SizedBox(height: 20),
              
              // Status Message Card
              _buildStatusMessageCard(),
              
              const SizedBox(height: 20),
              
              // Live Tracking Info
              if (_order.status == 'out_for_delivery')
                _buildLiveTrackingCard(),
              
              const SizedBox(height: 20),
              
              // Delivery Agent Card
              if (_order.deliveryAgent != null)
                _buildDeliveryAgentCard(),
              
              const SizedBox(height: 20),
              
              // Order Details Card
              _buildOrderDetailsCard(),
              
              const SizedBox(height: 20),
              
              // Timeline History
              _buildTimelineCard(),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryProgressCard() {
    final List<Map<String, dynamic>> steps = [
      {'status': 'pending', 'title': 'Order Placed', 'icon': Icons.receipt, 'color': Colors.orange},
      {'status': 'confirmed', 'title': 'Confirmed', 'icon': Icons.check_circle_outline, 'color': Colors.blue},
      {'status': 'processing', 'title': 'Preparing', 'icon': Icons.kitchen, 'color': Colors.purple},
      {'status': 'shipped', 'title': 'Picked Up', 'icon': Icons.local_shipping, 'color': Colors.cyan},
      {'status': 'out_for_delivery', 'title': 'Out for Delivery', 'icon': Icons.delivery_dining, 'color': Colors.teal},
      {'status': 'delivered', 'title': 'Delivered', 'icon': Icons.check_circle, 'color': Colors.green},
    ];
    
    int currentStep = -1;
    for (int i = 0; i < steps.length; i++) {
      if (steps[i]['status'] == _order.status) {
        currentStep = i;
        break;
      }
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Progress indicator
            SizedBox(
              height: 80,
              child: Row(
                children: List.generate(steps.length, (index) {
                  final isCompleted = index <= currentStep;
                  final isCurrent = index == currentStep;
                  final step = steps[index];
                  
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? step['color'] : Colors.grey.shade300,
                            border: isCurrent
                                ? Border.all(color: Colors.green, width: 3)
                                : null,
                          ),
                          child: Icon(
                            step['icon'],
                            size: 20,
                            color: isCompleted ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted ? step['color'] : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _order.getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _order.getStatusIcon(),
                color: _order.getStatusColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _order.getDeliveryStatusMessage(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTrackingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Live Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _order.currentLocation ?? 'Delivery agent is on the way',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Live map view coming soon',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAgentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delivery_dining, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Agent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                _order.deliveryAgent?.name ?? 'Delivery Partner',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('📞 Phone: ${_order.deliveryAgent?.phone ?? 'Not assigned yet'}'),
                  if (_order.deliveryAgent?.vehicleNumber != null)
                    Text('🚚 Vehicle: ${_order.deliveryAgent?.vehicleNumber}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () {
                  // TODO: Implement phone call
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.quantity} x ${item.productName}'),
                  Text('UGX ${item.price.toStringAsFixed(0)}'),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Address:'),
                Expanded(
                  child: Text(
                    _order.deliveryAddress,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment:'),
                Text(_order.paymentMethodDisplay),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'UGX ${_order.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_order.trackingHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No tracking history available')),
              )
            else
              ..._order.trackingHistory.map((tracking) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tracking['status_display'] ?? tracking['status'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (tracking['notes'] != null && tracking['notes'].isNotEmpty)
                            Text(
                              tracking['notes'],
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          Text(
                            _formatDateTime(DateTime.parse(tracking['timestamp'])),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}