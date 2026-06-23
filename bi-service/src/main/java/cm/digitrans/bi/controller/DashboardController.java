package cm.digitrans.bi.controller;

import cm.digitrans.bi.dto.DashboardSummary;
import cm.digitrans.bi.dto.OrdersByCity;
import cm.digitrans.bi.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    private final DashboardService dashboardService;

    @GetMapping("/summary")
    public ResponseEntity<DashboardSummary> getSummary(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(dashboardService.getSummary(token));
    }

    @GetMapping("/orders-by-city")
    public ResponseEntity<OrdersByCity> getOrdersByCity(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        return ResponseEntity.ok(dashboardService.getOrdersByCity(token));
    }
}
