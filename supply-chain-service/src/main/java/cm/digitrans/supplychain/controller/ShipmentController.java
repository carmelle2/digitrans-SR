package cm.digitrans.supplychain.controller;

import cm.digitrans.supplychain.dto.StatusUpdateRequest;
import cm.digitrans.supplychain.entity.Shipment;
import cm.digitrans.supplychain.service.ShipmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shipments")
@RequiredArgsConstructor
public class ShipmentController {
    private final ShipmentService shipmentService;

    @GetMapping
    public ResponseEntity<List<Shipment>> getAll() {
        return ResponseEntity.ok(shipmentService.findAll());
    }

    @PostMapping
    public ResponseEntity<Shipment> create(@RequestBody Shipment shipment) {
        return ResponseEntity.ok(shipmentService.save(shipment));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Shipment> updateStatus(@PathVariable Long id, @RequestBody StatusUpdateRequest request) {
        return ResponseEntity.ok(shipmentService.updateStatus(id, request.getStatus()));
    }
}
