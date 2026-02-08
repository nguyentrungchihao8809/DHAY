import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/place_search_placeholder_bloc.dart';
import '../widgets/location_input_field.dart';
import '../widgets/recent_destination_item.dart';
import '../widgets/custom_button.dart';

class PlaceSearchPage extends StatelessWidget {
  const PlaceSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN HEADER & INPUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'HDAY',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D5AFE)
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bạn muốn đi đâu?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// Ô NHẬP ĐIỂM ĐÓN
                  LocationInputField(
                    hintText: "Nhập điểm đón...",
                    icon: Icons.my_location,
                    onChanged: (value) {
                      context.read<PlaceSearchBloc>().add(
                        SearchQueryChanged(value, LocationFieldType.pickup),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  /// Ô NHẬP ĐIỂM ĐẾN
                  LocationInputField(
                    hintText: "Nhập điểm đến...",
                    icon: Icons.location_on,
                    onChanged: (value) {
                      context.read<PlaceSearchBloc>().add(
                        SearchQueryChanged(value, LocationFieldType.dropoff),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Kết quả tìm kiếm",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),

            // --- PHẦN HIỂN THỊ KẾT QUẢ TỪ BLOC ---
            Expanded(
              child: BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
                builder: (context, state) {
                  // 1. Trạng thái Loading
                  if (state is PlaceSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Trạng thái đã có dữ liệu
                  if (state is PlaceSearchLoaded) {
                    // Quyết định hiển thị list Pickup hay Dropoff dựa trên ô vừa gõ
                    final places = state.lastModifiedField == LocationFieldType.pickup
                        ? state.pickupPlaces
                        : state.dropoffPlaces;

                    if (places.isEmpty) {
                      return const Center(child: Text("Không tìm thấy địa điểm nào"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return RecentDestinationItem(
                          title: place.name.split(',').first, // Lấy phần tên chính
                          subtitle: place.name, // Địa chỉ đầy đủ
                          onTap: () {
                            // GỬI TỌA ĐỘ VỀ BACKEND SPRING BOOT
                            context.read<PlaceSearchBloc>().add(SelectPlaceEvent(place));

                            // Thông báo cho người dùng
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Đã chọn: ${place.name}"),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  // 3. Trạng thái lỗi
                  if (state is PlaceSearchError) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(color: Colors.red)),
                    );
                  }

                  // 4. Trạng thái mặc định (Initial)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
                        const Text("Nhập địa chỉ để bắt đầu chuyến đi",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- NÚT TIẾP TỤC ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                label: "Tiếp tục",
                onPressed: () {
                  // Xử lý chuyển màn hình sau khi chọn xong cả 2 điểm
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}