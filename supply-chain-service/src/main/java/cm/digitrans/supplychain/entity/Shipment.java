package cm.digitrans.supplychain.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "shipments")
@Data
public class Shipment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long productId;
    private String origine;
    private String destination;
    private String statut;
    private LocalDateTime date;
}
