package com.duan.hday.controller.matching;

import com.duan.hday.entity.Trip;
import com.duan.hday.repository.trip.TripRepository;
import com.duan.hday.service.AutoMatchingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/matching")
@RequiredArgsConstructor
public class MatchingController {

    private final AutoMatchingService matchingService;
    private final TripRepository tripRepository;

    // API 1: Xem tất cả khách hàng tiềm năng xung quanh (Chưa sắp xếp chỗ)
    @GetMapping("/candidates/{tripId}")
    public ResponseEntity<?> getPotentialPassengers(@PathVariable Long tripId) {
        Trip trip = tripRepository.findById(tripId).orElseThrow();
        return ResponseEntity.ok(matchingService.scanPotentialPassengers(trip));
    }

    // API 2: Hệ thống tự động tính toán cách lấp đầy ghế tối ưu nhất
    @GetMapping("/auto-optimize/{tripId}")
    public ResponseEntity<?> autoOptimize(@PathVariable Long tripId) {
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new RuntimeException("Trip not found"));
        
        // Gọi thuật toán phân đoạn ghế (Segment-based)
        var optimizedResults = matchingService.autoFillSeatsBySegments(trip);
        
        return ResponseEntity.ok(Map.of(
            "tripId", tripId,
            "totalMatched", optimizedResults.size(),
            "suggestedPassengers", optimizedResults
        ));
    }
}
