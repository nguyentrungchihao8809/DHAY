package com.duan.hday.service;

import com.duan.hday.entity.DriverProfile;
import com.duan.hday.entity.User;
import com.duan.hday.entity.Vehicle;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.duan.hday.repository.driver.DriverProfileRepository;
import com.duan.hday.repository.driver.VehicleRepository;
import com.duan.hday.repository.auth.UserRepository;
import com.duan.hday.dto.request.driver.DriverRegistrationRequest;

@Service
@RequiredArgsConstructor
public class DriverService {

    private final UserRepository userRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final VehicleRepository vehicleRepository;

    @Transactional
    public void registerAsDriver(Long userId, DriverRegistrationRequest request) {
        // 1. Kiểm tra User tồn tại (Fail-fast)
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        // 2. Kiểm tra tính hợp lệ của tài khoản người dùng
        if (!user.getIsActive() || user.getIsDeleted()) {
            throw new RuntimeException("Tài khoản người dùng đã bị khóa hoặc bị xóa");
        }

        // 3. Kiểm tra xem đã là tài xế chưa (Sử dụng exists để tối ưu hiệu năng)
        // Thay vì lấy cả object Profile ra, chỉ cần check sự tồn tại trong DB
        if (driverProfileRepository.existsById(userId)) {
            throw new RuntimeException("Bạn đã đăng ký làm tài xế trước đó rồi");
        }

        // 4. Tạo Driver Profile với trạng thái chờ duyệt
        DriverProfile profile = DriverProfile.builder()
                .user(user)
                .licenseNumber(request.getLicenseNumber())
                .isActive(true) // Senior Tip: Mặc định là false cho đến khi Admin duyệt
                .ratingAvg(5.0)  // Điểm uy tín ban đầu
                .totalTrips(0)
                .build();
        driverProfileRepository.save(profile);

        // 5. Kiểm tra biển số xe đã tồn tại trong hệ thống chưa (Chống trùng lặp)
        if (vehicleRepository.existsByVehiclePlate(request.getVehiclePlate())) {
            throw new RuntimeException("Biển số xe này đã được đăng ký trên hệ thống");
        }

        // 6. Tạo Vehicle gắn liền với User
        Vehicle vehicle = Vehicle.builder()
                .driver(user)
                .vehiclePlate(request.getVehiclePlate())
                .vehicleBrand(request.getVehicleBrand())
                .vehicleModel(request.getVehicleModel())
                .vehicleType(request.getVehicleType())
                .capacity(request.getCapacity())
                .isVerified(true) // Đợi admin kiểm tra giấy tờ xe
                .build();
        vehicleRepository.save(vehicle);
    }
}

