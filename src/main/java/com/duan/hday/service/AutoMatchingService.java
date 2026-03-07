package com.duan.hday.service;

import com.duan.hday.dto.request.driver.PotentialPassengerResponse;
import com.duan.hday.entity.PassengerTripRequest;
import com.duan.hday.entity.Trip;
import com.duan.hday.repository.passenger.PassengerTripRequestRepository;
import com.duan.hday.util.GeometryUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.locationtech.jts.geom.LineString;
import java.util.stream.Collectors;
import org.locationtech.jts.geom.Coordinate;
import jakarta.transaction.Transactional;
import org.locationtech.jts.simplify.DouglasPeuckerSimplifier;
import org.locationtech.jts.geom.Geometry;

import java.util.ArrayList;
import java.util.Comparator;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AutoMatchingService {

    private final PassengerTripRequestRepository requestRepository;
    private final NotificationService notificationService;

    public List<PotentialPassengerResponse> scanPotentialPassengers(Trip trip) {
        String wkt = GeometryUtils.castPolylineToWkt(trip.getRoutePolyline());
        LocalDateTime startTime = trip.getDepartureTime().minusMinutes(30);
        LocalDateTime endTime = trip.getDepartureTime().plusMinutes(30);

        // 1. Lọc thô bằng Spatial Query từ DB
        List<PassengerTripRequest> potentialMatches = requestRepository.findAllPotentialMatches(wkt, startTime, endTime);

        // 2. Chuyển đổi polyline để tính toán
        LineString routeLine = (LineString) GeometryUtils.wktToGeometry(wkt);
        Coordinate[] routeCoords = routeLine.getCoordinates();

        // 3. Lọc tinh và Map sang DTO
        return potentialMatches.stream()
            .filter(req -> {
                int startIndex = GeometryUtils.findNearestPointIndex(routeLine, req.getStartLocation().getGeom());
                int endIndex = GeometryUtils.findNearestPointIndex(routeLine, req.getEndLocation().getGeom());

                // Kiểm tra hướng
                if (startIndex >= endIndex) {
                    log.info("SKIPPED Request {}: Ngược chiều (StartIdx: {}, EndIdx: {})", req.getId(), startIndex, endIndex);
                    return false;
                }

                // Kiểm tra độ vòng vèo (Efficiency Ratio)
                double birdFlyDistance = req.getStartLocation().getGeom().distance(req.getEndLocation().getGeom());
                double routeDistance = 0;
                for (int i = startIndex; i < endIndex; i++) {
                    routeDistance += routeCoords[i].distance(routeCoords[i+1]);
                }

                if (routeDistance > birdFlyDistance * 2.5) {
                    log.info("SKIPPED Request {}: Quá vòng vèo (Ratio: {})", req.getId(), String.format("%.2f", routeDistance/birdFlyDistance));
                    return false;
                }

                return true;
            })
            .map(req -> {
                PotentialPassengerResponse res = convertToResponse(req);
                // TÍNH TOÁN ĐIỂM ƯU TIÊN (Ranking)
                res.setMatchScore(calculateScore(trip, req, routeLine)); 
                return res;
            })
            // Sắp xếp giảm dần theo điểm (Thằng nào điểm cao lên đầu)
            .sorted(Comparator.comparingDouble(PotentialPassengerResponse::getMatchScore).reversed())
            .collect(Collectors.toList());
        }

    private static final double WEIGHT_DISTANCE = 10.0;
    private static final double WEIGHT_PROXIMITY_PENALTY = 200.0;
    private static final double WEIGHT_TIME = 0.5;

    private double calculateScore(Trip trip, PassengerTripRequest req, LineString routeLine) {
    // 1. Khách đường dài: Tính bằng Mét (Geodetic)
        double passengerDistanceMeters = GeometryUtils.calculateDistanceMeters(
                req.getStartLocation().getGeom(), 
                req.getEndLocation().getGeom()
        );
        // Quy đổi điểm: 1km (1000m) = 10 điểm
        double distanceScore = (passengerDistanceMeters / 1000.0) * WEIGHT_DISTANCE;

        // 2. Độ lệch lộ trình (Proximity)
        // Tính khoảng cách từ điểm đón/trả đến Polyline (đơn vị Mét)
        double pickUpDeviation = GeometryUtils.distanceFromPointToLineMeters(req.getStartLocation().getGeom(), routeLine);
        double dropOffDeviation = GeometryUtils.distanceFromPointToLineMeters(req.getEndLocation().getGeom(), routeLine);
        
        // Phạt điểm: Cứ lệch 100m trừ X điểm (WEIGHT_PROXIMITY_PENALTY)
        double proximityScore = 100 - ((pickUpDeviation + dropOffDeviation) / 100.0) * WEIGHT_PROXIMITY_PENALTY;

        // 3. Ưu tiên thời gian (giữ nguyên)
        long minutesWaiting = 0;
        if (req.getCreatedAt() != null) {
            minutesWaiting = java.time.Duration.between(req.getCreatedAt(), LocalDateTime.now()).toMinutes();
        }
        double timeScore = minutesWaiting * WEIGHT_TIME;

        return distanceScore + proximityScore + timeScore;
    }

    private PotentialPassengerResponse convertToResponse(PassengerTripRequest req) {
        return PotentialPassengerResponse.builder()
                .requestId(req.getId())
                .passengerId(req.getPassenger().getId())
                .passengerName(req.getPassenger().getFullName())
                .startAddress(req.getStartLocation().getAddress())
                .startLat(req.getStartLocation().getLat())
                .startLng(req.getStartLocation().getLng())
                .endAddress(req.getEndLocation().getAddress())
                .endLat(req.getEndLocation().getLat())
                .endLng(req.getEndLocation().getLng())
                .seatsRequested(req.getSeatsRequested())
                .desiredTime(req.getDesiredDepartureTime().toString())
                .startGeom(req.getStartLocation().getGeom()) 
                .endGeom(req.getEndLocation().getGeom())
                .build();
    }

    /**
 * Thuật toán lấp đầy ghế theo phân đoạn (Segment-based Seat Filling)
 * Giúp tối ưu hóa việc đón nhiều khách trên cùng một ghế ở các quãng đường khác nhau.
 */
        @Transactional
        public List<PotentialPassengerResponse> autoFillSeatsBySegments(Trip trip) {
            // 1. Lấy Route gốc và LÀM MƯỢT (Simplify)
            String wkt = GeometryUtils.castPolylineToWkt(trip.getRoutePolyline());
            Geometry rawRoute = GeometryUtils.wktToGeometry(wkt);
            
            // Sử dụng DouglasPeucker để rút gọn điểm. 
            // Tolerance 0.0001 tương đương khoảng 10-15m, đủ để giữ độ chính xác trên bản đồ.
            LineString routeLine = (LineString) DouglasPeuckerSimplifier.simplify(rawRoute, 0.0001);
            
            Coordinate[] coords = routeLine.getCoordinates();
            int numPoints = coords.length;
            
            // 2. Khởi tạo mảng quản lý ghế trống (n điểm có n-1 đoạn)
            // Fix lỗi đường cụt: Đảm bảo ít nhất có 1 đoạn
            if (numPoints < 2) return new ArrayList<>();
            
            int[] segmentCapacity = new int[numPoints - 1];
            java.util.Arrays.fill(segmentCapacity, trip.getAvailableSeats());

            List<PotentialPassengerResponse> candidates = this.scanPotentialPassengers(trip);
            List<PotentialPassengerResponse> finalMatches = new ArrayList<>();

            for (PotentialPassengerResponse candidate : candidates) {
                int startIdx = GeometryUtils.findNearestPointIndex(routeLine, candidate.getStartGeom());
                int endIdx = GeometryUtils.findNearestPointIndex(routeLine, candidate.getEndGeom());

                // FIX LỖI ĐƯỜNG CỤT & BIÊN:
                // Đảm bảo startIdx luôn nhỏ hơn endIdx và không vượt quá giới hạn mảng
                if (startIdx < 0) startIdx = 0;
                if (endIdx >= numPoints) endIdx = numPoints - 1; 

                if (startIdx >= endIdx) {
                    log.warn("Bỏ qua khách {}: Vị trí không hợp lệ trên route đơn giản hóa", candidate.getPassengerName());
                    continue;
                }

                // 4. KIỂM TRA CHỖ TRỐNG
                boolean hasRoom = true;
                for (int i = startIdx; i < endIdx; i++) {
                    if (segmentCapacity[i] < candidate.getSeatsRequested()) {
                        hasRoom = false;
                        break;
                    }
                }

                // 5. CHIẾM GHẾ
                if (hasRoom) {
                    for (int i = startIdx; i < endIdx; i++) {
                        segmentCapacity[i] -= candidate.getSeatsRequested();
                    }
                    candidate.setSystemSuggested(true);
                    finalMatches.add(candidate);
                }
            }

            if (!finalMatches.isEmpty()) {
        // THÔNG BÁO CHO TÀI XẾ
                notificationService.sendNotification(
                    trip.getDriver().getId(),
                    "💡 Đã tìm thấy hành khách phù hợp!",
                    "Hệ thống đã tự động ghép cho bạn " + finalMatches.size() + " hành khách tiềm năng.",
                    Map.of("type", "MATCH_SUGGESTION", "tripId", trip.getId().toString())
                );
            }
            return finalMatches;
        }
}