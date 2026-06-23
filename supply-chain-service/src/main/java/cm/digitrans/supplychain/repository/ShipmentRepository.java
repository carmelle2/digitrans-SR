package cm.digitrans.supplychain.repository;

import cm.digitrans.supplychain.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShipmentRepository extends JpaRepository<Shipment, Long> {
}
