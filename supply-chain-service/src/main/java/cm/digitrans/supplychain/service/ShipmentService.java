package cm.digitrans.supplychain.service;

import cm.digitrans.supplychain.entity.Shipment;
import cm.digitrans.supplychain.repository.ShipmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ShipmentService {
    private final ShipmentRepository shipmentRepository;

    public List<Shipment> findAll() {
        return shipmentRepository.findAll();
    }

    public Shipment save(Shipment shipment) {
        return shipmentRepository.save(shipment);
    }

    public Shipment updateStatus(Long id, String status) {
        Shipment shipment = shipmentRepository.findById(id).orElseThrow();
        shipment.setStatut(status);
        return shipmentRepository.save(shipment);
    }
}
